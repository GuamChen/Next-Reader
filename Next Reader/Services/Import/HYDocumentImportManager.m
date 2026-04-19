//
//  HYDocumentImportManager.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYDocumentImportManager.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "HYAsyncTaskManager.h"
#import "HYDocumentItem.h"
#import "HYDocumentCacheManager.h"
#import "HYFileManagerService.h"

@interface HYDocumentImportManager () <UIDocumentPickerDelegate>

@property (nonatomic, weak) UIViewController *presentingViewController;

@end

@implementation HYDocumentImportManager

- (void)presentDocumentPickerFromViewController:(UIViewController *)viewController {
    self.presentingViewController = viewController;

    NSArray<NSString *> *documentTypes = @[
        (NSString *)kUTTypeData,
        @"com.adobe.pdf",
        @"org.openxmlformats.wordprocessingml.document",
        @"org.openxmlformats.spreadsheetml.sheet",
        @"org.openxmlformats.presentationml.presentation",
        (NSString *)kUTTypePlainText,
        @"net.daringfireball.markdown",
    ];

    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes
                                                                                                    inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    if (@available(iOS 11.0, *)) {
        picker.allowsMultipleSelection = YES;
    }
    [viewController presentViewController:picker animated:YES completion:nil];
}

- (void)handlePickedURLs:(NSArray<NSURL *> *)urls completion:(void (^ _Nullable)(NSArray<HYDocumentItem *> * _Nonnull))completion {
    dispatch_async([HYAsyncTaskManager sharedInstance].ioQueue, ^{
        @autoreleasepool {
            NSMutableArray<HYDocumentItem *> *items = [NSMutableArray array];
            NSError *lastError = nil;

            for (NSURL *url in urls) {
                BOOL didStartAccessing = [url startAccessingSecurityScopedResource];
                NSError *importError = nil;
                HYDocumentItem *item = [[HYFileManagerService sharedInstance] importDocumentFromScopedURL:url error:&importError];
                if (didStartAccessing) {
                    [url stopAccessingSecurityScopedResource];
                }
                if (item != nil) {
                    [items addObject:item];
                    [[HYDocumentCacheManager sharedInstance] cachePreviewMetaForDocument:item];
                } else if (importError != nil) {
                    lastError = importError;
                    HYLog(@"Document import failed for %@: %@", url.lastPathComponent, importError.localizedDescription);
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(items.copy);
                }
                if (self.importCompletion) {
                    NSError *uiError = lastError;
                    if (items.count == 0 && uiError == nil) {
                        uiError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                      code:HYDocumentImportErrorCodeCopyFailed
                                                  userInfo:@{NSLocalizedDescriptionKey: @"未成功导入任何文件。"}];
                    }
                    self.importCompletion(items.copy, uiError, NO);
                }
            });
        }
    });
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    [self handlePickedURLs:urls completion:nil];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if (self.importCompletion) {
        self.importCompletion(@[], nil, YES);
    }
}

@end
