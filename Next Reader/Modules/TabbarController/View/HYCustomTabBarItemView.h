//
//  HYCustomTabBarItemView.h
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import <UIKit/UIKit.h>

@class HYBaseLabel;

NS_ASSUME_NONNULL_BEGIN

@interface HYCustomTabBarItemView : UIControl

@property (nonatomic, strong) UIImageView *defaultIconView;
@property (nonatomic, strong) HYBaseLabel *titleLabel;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UIImageView *bubbleIconView;

- (instancetype)initWithTitle:(NSString *)title
                  normalImage:(UIImage *)normalImage
                selectedImage:(UIImage *)selectedImage;

- (void)setItemSelected:(BOOL)selected animated:(BOOL)animated;

@end
NS_ASSUME_NONNULL_END
