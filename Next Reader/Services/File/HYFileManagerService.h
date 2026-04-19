//
//  HYFileManagerService.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <Foundation/Foundation.h>

#import "HYDocumentItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ERROR_ENUM(NSCocoaErrorDomain, HYDocumentImportErrorCode) {
    HYDocumentImportErrorCodeMissingURL = 7001,
    HYDocumentImportErrorCodeUnsupportedType,
    HYDocumentImportErrorCodeUnreadable,
    HYDocumentImportErrorCodeTooLarge,
    HYDocumentImportErrorCodeCopyFailed,
};

@interface HYFileManagerService : NSObject

+ (instancetype)sharedInstance;
- (void)prepareManagedDirectoriesIfNeeded;
- (NSArray<HYDocumentItem *> *)fetchLocalDocuments;
- (nullable HYDocumentItem *)importDocumentFromScopedURL:(NSURL *)sourceURL error:(NSError * _Nullable __autoreleasing *)error;
- (HYDocumentType)documentTypeForPath:(NSString *)filePath;
- (NSString *)formattedFileSize:(unsigned long long)fileSize;
- (unsigned long long)cacheDirectorySize;
- (unsigned long long)tempDirectorySize;
- (unsigned long long)totalManagedCacheSize;
- (unsigned long long)clearCacheDirectory;
- (unsigned long long)clearTempDirectory;
- (unsigned long long)clearAllManagedCaches;

@end

NS_ASSUME_NONNULL_END
