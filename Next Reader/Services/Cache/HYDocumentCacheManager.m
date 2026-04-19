//
//  HYDocumentCacheManager.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYDocumentCacheManager.h"

#import "HYDocumentItem.h"

static NSString * const HYRecentPreviewRecordsDefaultsKey = @"com.nextreader.cache.recent.preview.records";
static NSUInteger const HYRecentPreviewRecordsMaximumCount = 20;
static NSUInteger const HYPreviewMetaCacheMaximumCount = 100;

@interface HYDocumentCacheManager ()

@property (nonatomic, strong) NSCache<NSString *, NSDictionary *> *previewMetaCache;

@end

@implementation HYDocumentCacheManager

+ (instancetype)sharedInstance {
    static HYDocumentCacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HYDocumentCacheManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _previewMetaCache = [[NSCache alloc] init];
        _previewMetaCache.countLimit = HYPreviewMetaCacheMaximumCount;
    }
    return self;
}

- (void)cachePreviewMetaForDocument:(HYDocumentItem *)item {
    if (item.filePath.length == 0) {
        return;
    }
    NSDictionary *meta = @{
        @"fileName": item.fileName ?: @"",
        @"filePath": item.filePath ?: @"",
        @"documentType": @(item.documentType),
        @"fileSize": @(item.fileSize),
        @"modifiedDate": item.modifiedDate ?: [NSDate dateWithTimeIntervalSince1970:0],
    };
    [self.previewMetaCache setObject:meta forKey:[self hy_cacheKeyForDocument:item]];
}

- (id)cachedPreviewMetaForDocument:(HYDocumentItem *)item {
    if (item.filePath.length == 0) {
        return nil;
    }
    return [self.previewMetaCache objectForKey:[self hy_cacheKeyForDocument:item]];
}

- (void)cacheRecentPreviewForDocument:(HYDocumentItem *)item {
    if (item.filePath.length == 0) {
        return;
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *records = [[self recentPreviewRecords] mutableCopy];
    NSIndexSet *duplicateIndexes = [records indexesOfObjectsPassingTest:^BOOL(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj[@"filePath"] isEqualToString:item.filePath];
    }];
    if (duplicateIndexes.count > 0) {
        [records removeObjectsAtIndexes:duplicateIndexes];
    }

    NSDictionary *record = @{
        @"fileName": item.fileName ?: @"",
        @"filePath": item.filePath ?: @"",
        @"documentType": @(item.documentType),
        @"modifiedDate": item.modifiedDate ?: [NSDate dateWithTimeIntervalSince1970:0],
        @"previewedAt": [NSDate date],
    };
    [records insertObject:record atIndex:0];
    if (records.count > HYRecentPreviewRecordsMaximumCount) {
        [records removeObjectsInRange:NSMakeRange(HYRecentPreviewRecordsMaximumCount, records.count - HYRecentPreviewRecordsMaximumCount)];
    }
    [[NSUserDefaults standardUserDefaults] setObject:records.copy forKey:HYRecentPreviewRecordsDefaultsKey];
}

- (NSArray<NSDictionary<NSString *,id> *> *)recentPreviewRecords {
    NSArray<NSDictionary<NSString *, id> *> *records = [[NSUserDefaults standardUserDefaults] arrayForKey:HYRecentPreviewRecordsDefaultsKey];
    return [records isKindOfClass:[NSArray class]] ? records : @[];
}

- (void)clearTempCacheIfNeeded {
    if (self.previewMetaCache.totalCostLimit > HYPreviewMetaCacheMaximumCount * 2) {
        [self.previewMetaCache removeAllObjects];
    }
    if (self.previewMetaCache.countLimit > HYPreviewMetaCacheMaximumCount) {
        self.previewMetaCache.countLimit = HYPreviewMetaCacheMaximumCount;
    }
}

- (NSString *)hy_cacheKeyForDocument:(HYDocumentItem *)item {
    NSTimeInterval modifiedTimestamp = item.modifiedDate.timeIntervalSince1970;
    return [NSString stringWithFormat:@"%@-%llu-%.0f", item.filePath ?: @"", item.fileSize, modifiedTimestamp];
}

@end
