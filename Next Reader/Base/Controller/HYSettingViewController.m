//
//  HYSettingViewController.m
//  Next Reader
//
//  Created by Gavin on 2026/4/16.
//

#import "HYSettingViewController.h"

@interface HYSettingViewController ()

@end

@implementation HYSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hy_setNavTitle:@"设置"];
    
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.text = @"设置页面（开发中）";
    tempLabel.textColor = HY_COLOR_TEXT_SECONDARY;
    tempLabel.font = HY_FONT(HY_FONT_SIZE_BODY);
    tempLabel.textAlignment = NSTextAlignmentCenter;
    [self.hy_contentView addSubview:tempLabel];
    
    [tempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.hy_contentView);
    }];
}

@end
