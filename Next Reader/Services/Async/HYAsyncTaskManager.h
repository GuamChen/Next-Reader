//
//  HYAsyncTaskManager.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYAsyncTaskManager : NSObject

@property (nonatomic, strong, readonly) dispatch_queue_t ioQueue;
@property (nonatomic, strong, readonly) dispatch_queue_t parseQueue;
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
