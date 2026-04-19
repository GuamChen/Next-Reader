//
//  HYCustomTabBarBackgroundView.h
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import <UIKit/UIKit.h>


static CGFloat const HYCustomTabBarHorizontalInset = 16.0f;
static CGFloat const HYCustomTabBarFloatingHeight = 28.0f;
static CGFloat const HYCustomTabBarBodyTop = 24.0f;
static CGFloat const HYCustomTabBarBodyHeight = 60.0f;
static CGFloat const HYCustomTabBarCornerRadius = 24.0f;
static CGFloat const HYCustomTabBarBubbleSize = 58.0f;




NS_ASSUME_NONNULL_BEGIN

@interface HYCustomTabBarBackgroundView : UIView

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGFloat safeBottomInset;

- (CGFloat)itemCenterXAtIndex:(NSInteger)index;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
