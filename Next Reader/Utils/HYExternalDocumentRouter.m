//
//  HYExternalDocumentRouter.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYExternalDocumentRouter.h"

#import "HYAsyncTaskManager.h"
#import "HYDocumentCacheManager.h"
#import "HYDocumentItem.h"
#import "HYDocumentPreviewViewController.h"
#import "HYFileManagerService.h"
#import "HYMainTabBarController.h"

@interface HYExternalDocumentRouter ()

@property (nonatomic, strong) dispatch_queue_t routingQueue;

@end

@implementation HYExternalDocumentRouter

+ (instancetype)sharedInstance {
    static HYExternalDocumentRouter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HYExternalDocumentRouter alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _routingQueue = [HYAsyncTaskManager sharedInstance].ioQueue;
    }
    return self;
}

- (BOOL)handleOpenURL:(NSURL *)url
              options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> * _Nullable)options {
    if (url == nil || !url.isFileURL) {
        return NO;
    }

    dispatch_async(self.routingQueue, ^{
        [self hy_importAndRouteURL:url];
    });
    return YES;
}

- (void)routeToPreviewWithLocalURL:(NSURL *)localURL {
    if (localURL == nil || !localURL.isFileURL) {
        return;
    }

    HYDocumentItem *documentItem = [self hy_documentItemForLocalURL:localURL];
    if (documentItem == nil) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:HYDocumentImportErrorCodeUnsupportedType
                                         userInfo:@{NSLocalizedDescriptionKey: @"当前文件类型暂不支持预览。"}];
        [self hy_presentImportFailure:error url:localURL];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self hy_routeToPreviewControllerWithItem:documentItem retryCount:0];
    });
}

#pragma mark - Import

- (void)hy_importAndRouteURL:(NSURL *)url {
    BOOL didStartAccessing = [url startAccessingSecurityScopedResource];
    NSError *importError = nil;
    HYDocumentItem *documentItem = [[HYFileManagerService sharedInstance] importDocumentFromScopedURL:url error:&importError];
    if (didStartAccessing) {
        [url stopAccessingSecurityScopedResource];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (documentItem == nil) {
            [self hy_presentImportFailure:importError url:url];
            return;
        }

        [[HYDocumentCacheManager sharedInstance] cachePreviewMetaForDocument:documentItem];
        [[HYDocumentCacheManager sharedInstance] cacheRecentPreviewForDocument:documentItem];
        [self hy_routeToPreviewControllerWithItem:documentItem retryCount:0];
    });
}

- (HYDocumentItem *)hy_documentItemForLocalURL:(NSURL *)localURL {
    NSString *filePath = localURL.path ?: HY_STRING_EMPTY;
    HYDocumentType documentType = [[HYFileManagerService sharedInstance] documentTypeForPath:filePath];
    if (documentType == HYDocumentTypeUnknown) {
        return nil;
    }

    NSDictionary<NSFileAttributeKey, id> *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    HYDocumentItem *item = [[HYDocumentItem alloc] init];
    item.fileName = localURL.lastPathComponent ?: HY_STRING_EMPTY;
    item.filePath = filePath;
    item.documentType = documentType;
    item.fileSize = [attributes[NSFileSize] unsignedLongLongValue];
    item.modifiedDate = attributes[NSFileModificationDate] ?: [NSDate date];
    return item;
}

#pragma mark - Routing

- (void)hy_routeToPreviewControllerWithItem:(HYDocumentItem *)documentItem retryCount:(NSUInteger)retryCount {
    UIWindow *window = [self hy_activeWindow];
    UIViewController *rootViewController = window.rootViewController;
    if (window == nil || rootViewController == nil) {
        [self hy_retryRouteWithItem:documentItem retryCount:retryCount];
        return;
    }

    HYMainTabBarController *tabBarController = [self hy_resolveTabBarControllerFromRoot:rootViewController];
    UINavigationController *navigationController = [self hy_resolveDocumentNavigationControllerFromRoot:rootViewController];
    if (tabBarController == nil || navigationController == nil) {
        [self hy_retryRouteWithItem:documentItem retryCount:retryCount];
        return;
    }

    tabBarController.selectedIndex = 0;
    __weak typeof(self) weakSelf = self;
    [rootViewController dismissViewControllerAnimated:NO completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        HYDocumentPreviewViewController *previewController = [[HYDocumentPreviewViewController alloc] initWithDocumentItem:documentItem];
        previewController.hidesBottomBarWhenPushed = YES;
        [navigationController pushViewController:previewController animated:YES];
    }];
}

- (void)hy_retryRouteWithItem:(HYDocumentItem *)documentItem retryCount:(NSUInteger)retryCount {
    if (retryCount >= 5) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:HYDocumentImportErrorCodeCopyFailed
                                         userInfo:@{NSLocalizedDescriptionKey: @"应用界面尚未准备完成，无法打开文档。"}];
        [self hy_presentImportFailure:error url:[NSURL fileURLWithPath:documentItem.filePath ?: HY_STRING_EMPTY]];
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hy_routeToPreviewControllerWithItem:documentItem retryCount:retryCount + 1];
    });
}

- (HYMainTabBarController *)hy_resolveTabBarControllerFromRoot:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[HYMainTabBarController class]]) {
        return (HYMainTabBarController *)rootViewController;
    }
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *firstViewController = ((UINavigationController *)rootViewController).viewControllers.firstObject;
        if ([firstViewController isKindOfClass:[HYMainTabBarController class]]) {
            return (HYMainTabBarController *)firstViewController;
        }
    }
    return nil;
}

- (UINavigationController *)hy_resolveDocumentNavigationControllerFromRoot:(UIViewController *)rootViewController {
    HYMainTabBarController *tabBarController = [self hy_resolveTabBarControllerFromRoot:rootViewController];
    if (tabBarController == nil || tabBarController.viewControllers.count == 0) {
        return nil;
    }

    UIViewController *documentController = tabBarController.viewControllers.firstObject;
    if ([documentController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)documentController;
    }
    return documentController.navigationController;
}

- (UIWindow *)hy_activeWindow {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState != UISceneActivationStateForegroundActive &&
                windowScene.activationState != UISceneActivationStateForegroundInactive) {
                continue;
            }
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
            UIWindow *firstWindow = windowScene.windows.firstObject;
            if (firstWindow != nil) {
                return firstWindow;
            }
        }
    }

    id<UIApplicationDelegate> appDelegate = UIApplication.sharedApplication.delegate;
    if ([appDelegate respondsToSelector:@selector(window)]) {
        return appDelegate.window;
    }
    return nil;
}

#pragma mark - UI

- (void)hy_presentImportFailure:(NSError *)error url:(NSURL *)url {
    NSString *message = error.localizedDescription;
    if (message.length == 0) {
        message = [NSString stringWithFormat:@"无法打开文件：%@", url.lastPathComponent ?: @"未知文件"];
    }

    UIViewController *rootViewController = [self hy_activeWindow].rootViewController;
    UIViewController *presentingController = [self hy_topPresentedViewControllerFromRoot:rootViewController];
    if (presentingController == nil) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打开失败"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
    [presentingController presentViewController:alertController animated:YES completion:nil];
}

- (UIViewController *)hy_topPresentedViewControllerFromRoot:(UIViewController *)rootViewController {
    if (rootViewController == nil) {
        return nil;
    }

    UIViewController *currentController = rootViewController;
    while (currentController.presentedViewController != nil) {
        currentController = currentController.presentedViewController;
    }

    if ([currentController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedController = ((UITabBarController *)currentController).selectedViewController;
        return [self hy_topPresentedViewControllerFromRoot:selectedController ?: currentController];
    }

    if ([currentController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visibleController = ((UINavigationController *)currentController).visibleViewController;
        return [self hy_topPresentedViewControllerFromRoot:visibleController ?: currentController];
    }

    return currentController;
}

@end
