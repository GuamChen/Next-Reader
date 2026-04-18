//
//  HYEmptyView.m
//  Next Reader
//
//  Created by Gavin on 2026/4/17.
//

#import "HYEmptyView.h"

@implementation HYEmptyView

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self hy_setupSubviews];
    }
    return self;
}

- (void)hy_setupSubviews {
    self.backgroundColor = HY_COLOR_BG_WHITE;

    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = HY_COLOR_TEXT_PRIMARY;
    self.titleLabel.font = HY_FONT_H3;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    [self addSubview:self.titleLabel];

    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.textColor = HY_COLOR_TEXT_SECONDARY;
    self.messageLabel.font = HY_FONT_CAPTION;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.numberOfLines = 0;
    [self addSubview:self.messageLabel];

    self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.retryButton.hidden = YES;
    self.retryButton.layer.cornerRadius = HY_CORNER_RADIUS_MD;
    self.retryButton.clipsToBounds = YES;
    self.retryButton.backgroundColor = HY_COLOR_THEME;
    self.retryButton.titleLabel.font = HY_FONT_MEDIUM(HY_FONT_SIZE_CAPTION);
    [self.retryButton setTitle:@"重新加载" forState:UIControlStateNormal];
    [self.retryButton setTitleColor:HY_COLOR_BG_WHITE forState:UIControlStateNormal];
    [self.retryButton addTarget:self action:@selector(hy_retryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.retryButton];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-70.0f);
        make.width.height.mas_equalTo(88.0f);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(HY_MARGIN_LG);
        make.left.equalTo(self).offset(HY_MARGIN_XXL);
        make.right.equalTo(self).offset(-HY_MARGIN_XXL);
    }];

    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(HY_MARGIN_XS);
        make.left.equalTo(self).offset(HY_MARGIN_XL);
        make.right.equalTo(self).offset(-HY_MARGIN_XL);
    }];

    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageLabel.mas_bottom).offset(HY_MARGIN_XL);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(120.0f);
        make.height.mas_equalTo(40.0f);
    }];
}

- (void)showInView:(UIView *)view {
    if (!view) {
        return;
    }

    if (!self.imageView.image) {
        self.imageView.image = [self hy_defaultPlaceholderImage];
    }

    if (self.superview != view) {
        [self removeFromSuperview];
        [view addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }
}

- (void)hide {
    [self removeFromSuperview];
}

- (void)hy_retryButtonTapped {
    if (self.retryBlock) {
        self.retryBlock();
    }
}

- (UIImage *)hy_defaultPlaceholderImage {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:@"doc.text"];
    }
    return nil;
}

@end
