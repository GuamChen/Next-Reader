//
//  HYExternalDocumentRouter.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYExternalDocumentRouter : NSObject

+ (instancetype)sharedInstance;

- (BOOL)handleOpenURL:(NSURL *)url
              options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> * _Nullable)options;

- (void)routeToPreviewWithLocalURL:(NSURL *)localURL;

@end

NS_ASSUME_NONNULL_END
