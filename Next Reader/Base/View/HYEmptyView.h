//
//  HYEmptyView.h
//  Next Reader
//
//  Created by Gavin on 2026/4/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// ==================== 空状态视图 ====================
@interface HYEmptyView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, copy) void(^retryBlock)(void);
- (void)showInView:(UIView *)view;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
