//
//  HYDocumentCacheManager.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <Foundation/Foundation.h>

@class HYDocumentItem;

NS_ASSUME_NONNULL_BEGIN

@interface HYDocumentCacheManager : NSObject

+ (instancetype)sharedInstance;
- (void)cachePreviewMetaForDocument:(HYDocumentItem *)item;
- (nullable id)cachedPreviewMetaForDocument:(HYDocumentItem *)item;
- (void)cacheRecentPreviewForDocument:(HYDocumentItem *)item;
- (NSArray<NSDictionary<NSString *, id> *> *)recentPreviewRecords;
- (void)clearTempCacheIfNeeded;

@end

NS_ASSUME_NONNULL_END
