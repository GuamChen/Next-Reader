//
//  HYCustomTabBarItemView.m
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import "HYCustomTabBarItemView.h"

@implementation HYCustomTabBarItemView {
    BOOL _itemSelected;
}

- (instancetype)initWithTitle:(NSString *)title
                  normalImage:(UIImage *)normalImage
                selectedImage:(UIImage *)selectedImage {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = UIColor.clearColor;

        _defaultIconView = [[UIImageView alloc] initWithImage:[normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _defaultIconView.tintColor = HY_COLOR_TEXT_TERTIARY;
        _defaultIconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_defaultIconView];

        _titleLabel = [HYUIBuildFactory labelWithFont:HY_FONT_SMALL
                                            textColor:HY_COLOR_TEXT_TERTIARY
                                            alignment:NSTextAlignmentCenter];
        _titleLabel.text = title;
        [self addSubview:_titleLabel];

        _bubbleView = [HYUIBuildFactory viewWithBackgroundColor:HY_COLOR_THEME];
        _bubbleView.layer.cornerRadius = HYCustomTabBarBubbleSize * 0.5f;
        _bubbleView.layer.shadowColor = [UIColor hy_colorWithHex:0x0052D9 alpha:0.38f].CGColor;
        _bubbleView.layer.shadowOpacity = 1.0f;
        _bubbleView.layer.shadowRadius = 16.0f;
        _bubbleView.layer.shadowOffset = CGSizeMake(0.0f, 8.0f);
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
    self.bubbleView.frame = CGRectMake((width - HYCustomTabBarBubbleSize) * 0.5f, 0.0f, HYCustomTabBarBubbleSize, HYCustomTabBarBubbleSize);
    self.bubbleIconView.frame = CGRectMake(17.0f, 17.0f, HYCustomTabBarBubbleSize - 34.0f, HYCustomTabBarBubbleSize - 34.0f);

    self.defaultIconView.frame = CGRectMake((width - 24.0f) * 0.5f, 34.0f, 24.0f, 24.0f);
    self.titleLabel.frame = CGRectMake(0.0f, 58.0f, width, 18.0f);
}

- (void)setItemSelected:(BOOL)selected animated:(BOOL)animated {
    _itemSelected = selected;

    void (^stateBlock)(void) = ^{
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
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:stateBlock
                     completion:nil];
}

@end
