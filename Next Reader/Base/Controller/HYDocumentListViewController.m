//
//  HYDocumentListViewController.m
//  Next Reader
//
//  Created by Gavin on 2026/4/16.
//

#import "HYDocumentListViewController.h"

@interface HYDocumentListViewController ()

@end

@implementation HYDocumentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hy_setNavTitle:@"我的文档"];
    [self hy_setRightButtonWithTitle:nil
                               image:@"nav_add"
                              target:self
                              action:@selector(addDocumentTapped)];
    
    // 临时内容
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.text = @"文档列表（开发中）";
    tempLabel.textColor = HY_COLOR_TEXT_SECONDARY;
    tempLabel.font = HY_FONT(HY_FONT_SIZE_BODY);
    tempLabel.textAlignment = NSTextAlignmentCenter;
    [self.hy_contentView addSubview:tempLabel];
    
    [tempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.hy_contentView);
    }];
}

- (void)addDocumentTapped {
    [self hy_showToast:@"添加文档"];
}

@end
