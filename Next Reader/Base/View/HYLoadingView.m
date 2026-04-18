//
//  HYLoadingView.m
//  Next Reader
//
//  Created by Gavin on 2026/4/17.
//

#import "HYLoadingView.h"

@implementation HYLoadingView

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self hy_setupSubviews];
    }
    return self;
}

- (void)hy_setupSubviews {
    self.backgroundColor = HY_COLOR_MASK_LIGHT;

    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor hy_colorWithHex:0x000000 alpha:0.75f];
    self.contentView.layer.cornerRadius = HY_CORNER_RADIUS_LG;
    self.contentView.clipsToBounds = YES;
    [self addSubview:self.contentView];

    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.contentView addSubview:self.indicator];

    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.textColor = HY_COLOR_BG_WHITE;
    self.messageLabel.font = HY_FONT_CAPTION;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.numberOfLines = 0;
    [self.contentView addSubview:self.messageLabel];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_greaterThanOrEqualTo(120.0f);
        make.height.mas_greaterThanOrEqualTo(120.0f);
        make.left.greaterThanOrEqualTo(self).offset(HY_MARGIN_XXL);
        make.right.lessThanOrEqualTo(self).offset(-HY_MARGIN_XXL);
    }];

    [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(HY_MARGIN_XL);
        make.centerX.equalTo(self.contentView);
    }];

    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.indicator.mas_bottom).offset(HY_MARGIN_SM);
        make.left.equalTo(self.contentView).offset(HY_MARGIN_MD);
        make.right.equalTo(self.contentView).offset(-HY_MARGIN_MD);
        make.bottom.equalTo(self.contentView).offset(-HY_MARGIN_XL);
    }];
}

- (void)showInView:(UIView *)view message:(NSString *)message {
    if (!view) {
        return;
    }

    if (self.superview != view) {
        [self removeFromSuperview];
        [view addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }

    self.messageLabel.text = HY_STRING_IS_EMPTY(message) ? @"加载中..." : message;
    [self.indicator startAnimating];
    self.hidden = NO;
    self.alpha = 0.0f;

    [UIView animateWithDuration:HY_ANIMATION_DURATION_NORMAL animations:^{
        self.alpha = 1.0f;
    }];
}

- (void)hide {
    [UIView animateWithDuration:HY_ANIMATION_DURATION_NORMAL animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.indicator stopAnimating];
        [self removeFromSuperview];
    }];
}

@end
