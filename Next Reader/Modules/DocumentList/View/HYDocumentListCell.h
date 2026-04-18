//
//  HYDocumentListCell.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <UIKit/UIKit.h>

@class HYDocumentItem;

NS_ASSUME_NONNULL_BEGIN

@interface HYDocumentListCell : UITableViewCell

+ (NSString *)reuseIdentifier;
- (void)configWithItem:(HYDocumentItem *)item;

@end

NS_ASSUME_NONNULL_END
