//
//  HYDocumentImportManager.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HYDocumentItem;

NS_ASSUME_NONNULL_BEGIN

@interface HYDocumentImportManager : NSObject

- (void)presentDocumentPickerFromViewController:(UIViewController *)viewController;
- (void)handlePickedURLs:(NSArray<NSURL *> *)urls completion:(nullable void(^)(NSArray<HYDocumentItem *> *items))completion;
@property (nonatomic, copy, nullable) void(^importCompletion)(NSArray<HYDocumentItem *> *items, NSError * _Nullable error, BOOL cancelled);

@end

NS_ASSUME_NONNULL_END
