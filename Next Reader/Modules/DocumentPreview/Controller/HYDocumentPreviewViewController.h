//
//  HYDocumentPreviewViewController.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYBaseViewController.h"

@class HYDocumentItem;

NS_ASSUME_NONNULL_BEGIN

@interface HYDocumentPreviewViewController : HYBaseViewController

- (instancetype)initWithDocumentItem:(HYDocumentItem *)documentItem;

@end

NS_ASSUME_NONNULL_END
