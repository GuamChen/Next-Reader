//
//  HYToastView.h
//  Next Reader
//
//  Created by Gavin on 2026/4/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// ==================== Toast 视图 ====================
@interface HYToastView : UIView
@property (nonatomic, strong) UILabel *textLabel;
+ (void)showInView:(UIView *)view text:(NSString *)text duration:(NSTimeInterval)duration;
@end
NS_ASSUME_NONNULL_END
