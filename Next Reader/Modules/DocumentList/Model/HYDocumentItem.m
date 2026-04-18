//
//  HYDocumentItem.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYDocumentItem.h"

@implementation HYDocumentItem

- (NSString *)typeDisplayName {
    switch (self.documentType) {
        case HYDocumentTypePDF:
            return @"PDF";
        case HYDocumentTypeWord:
            return @"Word";
        case HYDocumentTypeExcel:
            return @"Excel";
        case HYDocumentTypePPT:
            return @"PPT";
        case HYDocumentTypeText:
            return @"Text";
        case HYDocumentTypeMarkdown:
            return @"Markdown";
        case HYDocumentTypeUnknown:
        default:
            return @"Unknown";
    }
}

- (NSString *)typeBadgeText {
    switch (self.documentType) {
        case HYDocumentTypePDF:
            return @"PDF";
        case HYDocumentTypeWord:
            return @"DOC";
        case HYDocumentTypeExcel:
            return @"XLS";
        case HYDocumentTypePPT:
            return @"PPT";
        case HYDocumentTypeText:
            return @"TXT";
        case HYDocumentTypeMarkdown:
            return @"MD";
        case HYDocumentTypeUnknown:
        default:
            return @"FILE";
    }
}

- (NSString *)typeSystemImageName {
    switch (self.documentType) {
        case HYDocumentTypePDF:
            return @"doc.richtext";
        case HYDocumentTypeWord:
            return @"doc.text";
        case HYDocumentTypeExcel:
            return @"tablecells";
        case HYDocumentTypePPT:
            return @"display";
        case HYDocumentTypeText:
            return @"doc.plaintext";
        case HYDocumentTypeMarkdown:
            return @"chevron.left.forwardslash.chevron.right";
        case HYDocumentTypeUnknown:
        default:
            return @"doc";
    }
}

@end
