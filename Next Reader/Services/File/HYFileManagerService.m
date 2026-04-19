//
//  HYFileManagerService.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYFileManagerService.h"

#import "HYDocumentItem.h"

static unsigned long long const HYDocumentImportMaximumFileSize = 200 * 1024 * 1024;

@implementation HYFileManagerService

+ (instancetype)sharedInstance {
    static HYFileManagerService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HYFileManagerService alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareManagedDirectoriesIfNeeded];
    }
    return self;
}

- (void)prepareManagedDirectoriesIfNeeded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSURL *> *directoryURLs = @[
        [self hy_importDirectoryURL],
        [self hy_cacheDirectoryURL],
        [self hy_tempDirectoryURL],
    ];

    for (NSURL *directoryURL in directoryURLs) {
        if (![fileManager fileExistsAtPath:directoryURL.path]) {
            [fileManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

- (NSArray<HYDocumentItem *> *)fetchLocalDocuments {
    NSMutableArray<HYDocumentItem *> *documents = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    [self prepareManagedDirectoriesIfNeeded];
    NSArray<NSURL *> *rootURLs = [self hy_documentRootURLs];
    NSArray<NSURLResourceKey> *keys = @[
        NSURLIsDirectoryKey,
        NSURLNameKey,
        NSURLFileSizeKey,
        NSURLContentModificationDateKey,
        NSURLIsHiddenKey,
    ];

    for (NSURL *rootURL in rootURLs) {
        BOOL isDirectory = NO;
        if (![fileManager fileExistsAtPath:rootURL.path isDirectory:&isDirectory] || !isDirectory) {
            continue;
        }

        NSDirectoryEnumerator<NSURL *> *enumerator = [fileManager enumeratorAtURL:rootURL
                                                        includingPropertiesForKeys:keys
                                                                           options:NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                                                      errorHandler:nil];
        for (NSURL *fileURL in enumerator) {
            NSNumber *isDirectoryValue = nil;
            [fileURL getResourceValue:&isDirectoryValue forKey:NSURLIsDirectoryKey error:nil];
            if (isDirectoryValue.boolValue) {
                continue;
            }

            HYDocumentType documentType = [self documentTypeForPath:fileURL.path];
            if (documentType == HYDocumentTypeUnknown) {
                continue;
            }

            NSNumber *fileSizeValue = nil;
            NSDate *modifiedDate = nil;
            [fileURL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:nil];
            [fileURL getResourceValue:&modifiedDate forKey:NSURLContentModificationDateKey error:nil];

            HYDocumentItem *item = [[HYDocumentItem alloc] init];
            item.fileName = fileURL.lastPathComponent ?: HY_STRING_EMPTY;
            item.filePath = fileURL.path ?: HY_STRING_EMPTY;
            item.documentType = documentType;
            item.fileSize = fileSizeValue.unsignedLongLongValue;
            item.modifiedDate = modifiedDate ?: [NSDate dateWithTimeIntervalSince1970:0];
            [documents addObject:item];
        }
    }

    [documents sortUsingComparator:^NSComparisonResult(HYDocumentItem *obj1, HYDocumentItem *obj2) {
        return [obj2.modifiedDate compare:obj1.modifiedDate];
    }];

    return documents.copy;
}

- (HYDocumentItem *)importDocumentFromScopedURL:(NSURL *)sourceURL error:(NSError * _Nullable __autoreleasing *)error {
    if (sourceURL == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:HYDocumentImportErrorCodeMissingURL
                                     userInfo:@{NSLocalizedDescriptionKey: @"未获取到可导入的文件。"}];
        }
        return nil;
    }

    HYDocumentType documentType = [self documentTypeForPath:sourceURL.path];
    if (documentType == HYDocumentTypeUnknown) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:HYDocumentImportErrorCodeUnsupportedType
                                     userInfo:@{NSLocalizedDescriptionKey: @"当前文件类型暂不支持导入。"}];
        }
        return nil;
    }

    NSNumber *isReadable = nil;
    NSNumber *fileSizeValue = nil;
    NSNumber *isRegularFile = nil;
    [sourceURL getResourceValue:&isReadable forKey:NSURLIsReadableKey error:nil];
    [sourceURL getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:nil];
    [sourceURL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:nil];
    if (!isRegularFile.boolValue || !isReadable.boolValue) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:HYDocumentImportErrorCodeUnreadable
                                     userInfo:@{NSLocalizedDescriptionKey: @"外部文件不可读，无法导入。"}];
        }
        return nil;
    }

    if (fileSizeValue != nil && fileSizeValue.unsignedLongLongValue > HYDocumentImportMaximumFileSize) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:HYDocumentImportErrorCodeTooLarge
                                     userInfo:@{NSLocalizedDescriptionKey: @"当前文件过大，暂不支持导入超过 200MB 的文档。"}];
        }
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [self prepareManagedDirectoriesIfNeeded];
    NSURL *importDirectoryURL = [self hy_importDirectoryURL];
    NSURL *destinationURL = [self hy_uniqueDestinationURLForFileName:sourceURL.lastPathComponent ?: @"ImportedFile"
                                                        directoryURL:importDirectoryURL];
    BOOL copySucceeded = [fileManager copyItemAtURL:sourceURL toURL:destinationURL error:error];
    if (!copySucceeded) {
        if (error != NULL && *error == nil) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:HYDocumentImportErrorCodeCopyFailed
                                     userInfo:@{NSLocalizedDescriptionKey: @"文件复制失败，请稍后重试。"}];
        }
        return nil;
    }

    NSDictionary<NSFileAttributeKey, id> *attributes = [fileManager attributesOfItemAtPath:destinationURL.path error:nil];
    HYDocumentItem *item = [[HYDocumentItem alloc] init];
    item.fileName = destinationURL.lastPathComponent ?: HY_STRING_EMPTY;
    item.filePath = destinationURL.path ?: HY_STRING_EMPTY;
    item.documentType = documentType;
    item.fileSize = [attributes[NSFileSize] unsignedLongLongValue];
    item.modifiedDate = attributes[NSFileModificationDate] ?: [NSDate date];
    return item;
}

- (HYDocumentType)documentTypeForPath:(NSString *)filePath {
    NSString *extension = filePath.pathExtension.lowercaseString;
    if (extension.length == 0) {
        return HYDocumentTypeUnknown;
    }

    static NSDictionary<NSString *, NSNumber *> *typeMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeMap = @{
            @"pdf": @(HYDocumentTypePDF),
            @"doc": @(HYDocumentTypeWord),
            @"docx": @(HYDocumentTypeWord),
            @"xls": @(HYDocumentTypeExcel),
            @"xlsx": @(HYDocumentTypeExcel),
            @"ppt": @(HYDocumentTypePPT),
            @"pptx": @(HYDocumentTypePPT),
            @"txt": @(HYDocumentTypeText),
            @"text": @(HYDocumentTypeText),
            @"md": @(HYDocumentTypeMarkdown),
            @"markdown": @(HYDocumentTypeMarkdown),
        };
    });

    NSNumber *typeValue = typeMap[extension];
    return typeValue != nil ? typeValue.unsignedIntegerValue : HYDocumentTypeUnknown;
}

- (NSString *)formattedFileSize:(unsigned long long)fileSize {
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.allowedUnits = NSByteCountFormatterUseAll;
    formatter.countStyle = NSByteCountFormatterCountStyleFile;
    formatter.includesUnit = YES;
    return [formatter stringFromByteCount:(long long)fileSize];
}

- (unsigned long long)cacheDirectorySize {
    return [self hy_directorySizeAtURL:[self hy_cacheDirectoryURL]];
}

- (unsigned long long)tempDirectorySize {
    return [self hy_directorySizeAtURL:[self hy_tempDirectoryURL]];
}

- (unsigned long long)totalManagedCacheSize {
    return [self cacheDirectorySize] + [self tempDirectorySize];
}

- (unsigned long long)clearCacheDirectory {
    return [self hy_clearDirectoryAtURL:[self hy_cacheDirectoryURL]];
}

- (unsigned long long)clearTempDirectory {
    return [self hy_clearDirectoryAtURL:[self hy_tempDirectoryURL]];
}

- (unsigned long long)clearAllManagedCaches {
    unsigned long long clearedCacheSize = [self clearCacheDirectory];
    unsigned long long clearedTempSize = [self clearTempDirectory];
    return clearedCacheSize + clearedTempSize;
}

- (NSArray<NSURL *> *)hy_documentRootURLs {
    NSMutableArray<NSURL *> *rootURLs = [NSMutableArray array];

    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    if (documentsURL) {
        [rootURLs addObject:[self hy_importDirectoryURL]];
    }

    NSURL *libraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] firstObject];
    if (libraryURL) {
        NSURL *inboxURL = [libraryURL URLByAppendingPathComponent:@"Inbox" isDirectory:YES];
        [rootURLs addObject:inboxURL];
    }

    return rootURLs.copy;
}

- (NSURL *)hy_importDirectoryURL {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [documentsURL URLByAppendingPathComponent:@"Imported" isDirectory:YES];
}

- (NSURL *)hy_cacheDirectoryURL {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [documentsURL URLByAppendingPathComponent:@"Cache" isDirectory:YES];
}

- (NSURL *)hy_tempDirectoryURL {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [documentsURL URLByAppendingPathComponent:@"Temp" isDirectory:YES];
}

- (NSURL *)hy_uniqueDestinationURLForFileName:(NSString *)fileName directoryURL:(NSURL *)directoryURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *baseName = [fileName stringByDeletingPathExtension];
    NSString *pathExtension = fileName.pathExtension;
    NSURL *destinationURL = [directoryURL URLByAppendingPathComponent:fileName];
    NSUInteger index = 1;

    while ([fileManager fileExistsAtPath:destinationURL.path]) {
        NSString *candidateName = nil;
        if (pathExtension.length > 0) {
            candidateName = [NSString stringWithFormat:@"%@(%lu).%@", baseName, (unsigned long)index, pathExtension];
        } else {
            candidateName = [NSString stringWithFormat:@"%@(%lu)", baseName, (unsigned long)index];
        }
        destinationURL = [directoryURL URLByAppendingPathComponent:candidateName];
        index += 1;
    }

    return destinationURL;
}

- (unsigned long long)hy_clearDirectoryAtURL:(NSURL *)directoryURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSURLResourceKey> *resourceKeys = @[NSURLIsDirectoryKey, NSURLFileSizeKey];
    NSDirectoryEnumerator<NSURL *> *enumerator = [fileManager enumeratorAtURL:directoryURL
                                                  includingPropertiesForKeys:resourceKeys
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                errorHandler:nil];
    unsigned long long clearedSize = 0;
    NSMutableArray<NSURL *> *subdirectoryURLs = [NSMutableArray array];

    for (NSURL *fileURL in enumerator) {
        NSNumber *isDirectory = nil;
        NSNumber *fileSize = nil;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if (isDirectory.boolValue) {
            [subdirectoryURLs addObject:fileURL];
            continue;
        }

        [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        clearedSize += fileSize.unsignedLongLongValue;
        [fileManager removeItemAtURL:fileURL error:nil];
    }

    for (NSURL *subdirectoryURL in [subdirectoryURLs reverseObjectEnumerator]) {
        [fileManager removeItemAtURL:subdirectoryURL error:nil];
    }

    [self prepareManagedDirectoriesIfNeeded];
    return clearedSize;
}

- (unsigned long long)hy_directorySizeAtURL:(NSURL *)directoryURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSURLResourceKey> *resourceKeys = @[NSURLIsDirectoryKey, NSURLFileSizeKey];
    NSDirectoryEnumerator<NSURL *> *enumerator = [fileManager enumeratorAtURL:directoryURL
                                                  includingPropertiesForKeys:resourceKeys
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                errorHandler:nil];
    unsigned long long directorySize = 0;

    for (NSURL *fileURL in enumerator) {
        NSNumber *isDirectory = nil;
        NSNumber *fileSize = nil;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if (isDirectory.boolValue) {
            continue;
        }
        [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        directorySize += fileSize.unsignedLongLongValue;
    }

    return directorySize;
}

@end
