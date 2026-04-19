//
//  HYTabPlaceholderViewController.m
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import "HYTabPlaceholderViewController.h"

@interface HYTabPlaceholderViewController ()

@end

@implementation HYTabPlaceholderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor hy_colorWithHex:0xF3F6FB];

    UIView *cardView = [HYUIBuildFactory viewWithBackgroundColor:HY_COLOR_BG_WHITE];
    cardView.layer.cornerRadius = 24.0f;
    cardView.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.08f].CGColor;
    cardView.layer.shadowOpacity = 1.0f;
    cardView.layer.shadowRadius = 18.0f;
    cardView.layer.shadowOffset = CGSizeMake(0.0f, 10.0f);
    [self.view addSubview:cardView];

    UILabel *titleLabel = [HYUIBuildFactory labelWithFont:HY_FONT_MEDIUM(24.0f)
                                                textColor:HY_COLOR_TEXT_PRIMARY
                                                alignment:NSTextAlignmentCenter];
    titleLabel.text = @"viewcontroller";
    [cardView addSubview:titleLabel];

    UILabel *detailLabel = [HYUIBuildFactory labelWithFont:HY_FONT_CAPTION
                                                 textColor:HY_COLOR_TEXT_SECONDARY
                                                 alignment:NSTextAlignmentCenter];
    detailLabel.text = @"中间占位页";
    [cardView addSubview:detailLabel];

    UIView *accentView = [HYUIBuildFactory viewWithBackgroundColor:HY_COLOR_THEME];
    accentView.layer.cornerRadius = 14.0f;
    [cardView addSubview:accentView];

    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.equalTo(self.view).offset(HY_MARGIN_XL);
        make.right.equalTo(self.view).offset(-HY_MARGIN_XL);
        make.height.mas_equalTo(220.0f);
    }];

    [accentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cardView).offset(20.0f);
        make.centerX.equalTo(cardView);
        make.width.mas_equalTo(72.0f);
        make.height.mas_equalTo(8.0f);
    }];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(cardView);
        make.centerY.equalTo(cardView).offset(-8.0f);
    }];

    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(12.0f);
        make.centerX.equalTo(cardView);
    }];
}

@end
