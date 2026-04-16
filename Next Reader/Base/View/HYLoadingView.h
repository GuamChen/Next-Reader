//
//  HYLoadingView.h
//  Next Reader
//
//  Created by Gavin on 2026/4/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// ==================== Loading 视图 ====================
@interface HYLoadingView : UIView
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *contentView;
- (void)showInView:(UIView *)view message:(NSString *)message;
- (void)hide;
@end
NS_ASSUME_NONNULL_END
