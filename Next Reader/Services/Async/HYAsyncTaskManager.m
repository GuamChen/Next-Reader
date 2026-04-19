//
//  HYAsyncTaskManager.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYAsyncTaskManager.h"

@interface HYAsyncTaskManager ()

@property (nonatomic, strong, readwrite) dispatch_queue_t ioQueue;
@property (nonatomic, strong, readwrite) dispatch_queue_t parseQueue;

@end

@implementation HYAsyncTaskManager

+ (instancetype)sharedInstance {
    static HYAsyncTaskManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HYAsyncTaskManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _ioQueue = dispatch_queue_create("com.nextreader.io", DISPATCH_QUEUE_CONCURRENT);
        _parseQueue = dispatch_queue_create("com.nextreader.parse", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

@end
