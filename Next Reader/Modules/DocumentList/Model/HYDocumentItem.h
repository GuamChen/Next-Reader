//
//  HYDocumentItem.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HYDocumentType) {
    HYDocumentTypeUnknown = 0,
    HYDocumentTypePDF,
    HYDocumentTypeWord,
    HYDocumentTypeExcel,
    HYDocumentTypePPT,
    HYDocumentTypeText,
    HYDocumentTypeMarkdown,
};

@interface HYDocumentItem : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) HYDocumentType documentType;
@property (nonatomic, assign) unsigned long long fileSize;
@property (nonatomic, strong) NSDate *modifiedDate;

- (NSString *)typeDisplayName;
- (NSString *)typeBadgeText;
- (NSString *)typeSystemImageName;

@end

NS_ASSUME_NONNULL_END
