//
//  HYCustomTabBarItemView.m
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import "HYCustomTabBarItemView.h"

static CGFloat const HYCustomTabBarBubbleSize = 58.0f;
static CGFloat const HYCustomTabBarBubbleTopInset = 8.0f;

@implementation HYCustomTabBarItemView {
    BOOL _itemSelected;
}

- (instancetype)initWithTitle:(NSString *)title
                  normalImage:(UIImage *)normalImage
                selectedImage:(UIImage *)selectedImage {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = UIColor.clearColor;

        // 默认态图标：灰色线性 icon，始终保留在 item 的常规布局里。
        _defaultIconView = [[UIImageView alloc] initWithImage:[normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _defaultIconView.tintColor = HY_COLOR_TEXT_TERTIARY;
        _defaultIconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_defaultIconView];

        // 默认态标题：只有未选中时可见，选中后会淡出。
        _titleLabel = [HYUIBuildFactory labelWithFont:HY_FONT_SMALL
                                            textColor:HY_COLOR_TEXT_TERTIARY
                                            alignment:NSTextAlignmentCenter];
        _titleLabel.text = title;
        [self addSubview:_titleLabel];

        // 选中态蓝色圆球：和默认 icon/title 同时存在，通过 alpha/transform 切换状态。
        _bubbleView = [HYUIBuildFactory viewWithBackgroundColor:HY_COLOR_THEME];
        _bubbleView.layer.cornerRadius = HYCustomTabBarBubbleSize * 0.5f;
        _bubbleView.layer.shadowColor = [UIColor hy_colorWithHex:0x0052D9 alpha:0.38f].CGColor;
        _bubbleView.layer.shadowOpacity = 0.9f;
        _bubbleView.layer.shadowRadius = 14.0f;
        _bubbleView.layer.shadowOffset = CGSizeMake(0.0f, 6.0f);
        [self addSubview:_bubbleView];

        _bubbleIconView = [[UIImageView alloc] initWithImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _bubbleIconView.tintColor = HY_COLOR_BG_WHITE;
        _bubbleIconView.contentMode = UIViewContentModeScaleAspectFit;
        [_bubbleView addSubview:_bubbleIconView];

        [self setItemSelected:NO animated:NO];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    // 圆球上浮，但仍然放在 item 自己的坐标系里，这样点击热区不会丢。
    self.bubbleView.frame = CGRectMake((width - HYCustomTabBarBubbleSize) * 0.5f, HYCustomTabBarBubbleTopInset, HYCustomTabBarBubbleSize, HYCustomTabBarBubbleSize);
    self.bubbleIconView.frame = CGRectMake(17.0f, 17.0f, HYCustomTabBarBubbleSize - 34.0f, HYCustomTabBarBubbleSize - 34.0f);

    self.defaultIconView.frame = CGRectMake((width - 24.0f) * 0.5f, 38.0f, 24.0f, 24.0f);
    self.titleLabel.frame = CGRectMake(0.0f, 61.0f, width, 18.0f);
}

- (void)setItemSelected:(BOOL)selected animated:(BOOL)animated {
    _itemSelected = selected;

    void (^stateBlock)(void) = ^{
        // 这里不做层级切换，只做 alpha 和 transform 过渡，动画更稳定也更容易维护。
        self.defaultIconView.alpha = selected ? 0.0f : 1.0f;
        self.titleLabel.alpha = selected ? 0.0f : 1.0f;
        self.bubbleView.alpha = selected ? 1.0f : 0.0f;
        self.bubbleView.transform = selected ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.72f, 0.72f);
        self.defaultIconView.transform = selected ? CGAffineTransformMakeScale(0.82f, 0.82f) : CGAffineTransformIdentity;
        self.titleLabel.transform = selected ? CGAffineTransformMakeTranslation(0.0f, 6.0f) : CGAffineTransformIdentity;
    };

    if (!animated) {
        stateBlock();
        return;
    }

    [UIView animateWithDuration:HY_ANIMATION_DURATION_SLOW
                          delay:0.0f
         usingSpringWithDamping:0.82f
          initialSpringVelocity:0.45f
                        // item 的状态动画交给 UIView，背景路径动画交给 CAShapeLayer，两者分工明确。
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:stateBlock
                     completion:nil];
}

@end
