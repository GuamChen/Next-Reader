//
//  SceneDelegate.m
//  Next Reader
//
//  Created by Gavin on 2026/4/15.
//

#import "SceneDelegate.h"
#import "HYExternalDocumentRouter.h"
#import "HYMainTabBarController.h"
#import "SplashScreenController.h"

@interface SceneDelegate ()
@property (nonatomic, strong) SplashScreenController *launchScreenVC;

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
                 options:(UISceneConnectionOptions *)connectionOptions API_AVAILABLE(ios(13.0)) {
    
    // 创建 window 并设置根控制器
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.backgroundColor = HY_COLOR_BG_WHITE;
    
    HYMainTabBarController *tabBarController = [[HYMainTabBarController alloc] init];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    // 显示开屏界面
    [self showLaunchScreen];
    

    // 处理外部链接
    UIOpenURLContext *openURLContext = connectionOptions.URLContexts.allObjects.firstObject;
    if (openURLContext.URL != nil) {
        [[HYExternalDocumentRouter sharedInstance] handleOpenURL:openURLContext.URL options:nil];
    }
}


- (void)showLaunchScreen {
    self.launchScreenVC = [[SplashScreenController alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.launchScreenVC showInWindow:self.window completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // 开屏结束后的回调，可以在这里做一些初始化工作
        strongSelf.launchScreenVC = nil;
        NSLog(@"开屏界面已关闭");
    }];
}


- (void)sceneDidDisconnect:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景被系统释放时调用
}

- (void)sceneDidBecomeActive:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景从非活跃状态变为活跃状态
}

- (void)sceneWillResignActive:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景即将从活跃状态变为非活跃状态
}

- (void)sceneWillEnterForeground:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景即将进入前台
}

- (void)sceneDidEnterBackground:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景进入后台时的清理工作
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts API_AVAILABLE(ios(13.0)) {
    UIOpenURLContext *openURLContext = URLContexts.allObjects.firstObject;
    if (openURLContext.URL == nil) {
        return;
    }
    [[HYExternalDocumentRouter sharedInstance] handleOpenURL:openURLContext.URL options:nil];
}

@end
