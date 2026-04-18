//
//  HYFileManagerService.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYFileManagerService.h"

#import "HYDocumentItem.h"

@implementation HYFileManagerService

+ (instancetype)sharedInstance {
    static HYFileManagerService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HYFileManagerService alloc] init];
    });
    return instance;
}

- (NSArray<HYDocumentItem *> *)fetchLocalDocuments {
    NSMutableArray<HYDocumentItem *> *documents = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];

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

- (NSArray<NSURL *> *)hy_documentRootURLs {
    NSMutableArray<NSURL *> *rootURLs = [NSMutableArray array];

    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    if (documentsURL) {
        [rootURLs addObject:documentsURL];
    }

    NSURL *libraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] firstObject];
    if (libraryURL) {
        NSURL *inboxURL = [libraryURL URLByAppendingPathComponent:@"Inbox" isDirectory:YES];
        [rootURLs addObject:inboxURL];
    }

    return rootURLs.copy;
}

@end
