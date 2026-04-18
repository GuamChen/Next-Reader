//
//  HYFileManagerService.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <Foundation/Foundation.h>

#import "HYDocumentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYFileManagerService : NSObject

+ (instancetype)sharedInstance;
- (NSArray<HYDocumentItem *> *)fetchLocalDocuments;
- (HYDocumentType)documentTypeForPath:(NSString *)filePath;
- (NSString *)formattedFileSize:(unsigned long long)fileSize;

@end

NS_ASSUME_NONNULL_END
