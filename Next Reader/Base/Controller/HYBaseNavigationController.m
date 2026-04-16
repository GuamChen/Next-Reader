//
//  HYBaseNavigationController 2.h
//  Next Reader
//
//  Created by Gavin on 2026/4/17.
//


//
//  HYBaseNavigationController.m
//  极速文档阅读器
//
//  Created by Tencent iOS Team
//

#import "HYBaseNavigationController.h"

@interface HYBaseNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation HYBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏为隐藏（因为我们使用自定义导航栏）
    [self setNavigationBarHidden:YES animated:NO];
    
    // 启用侧滑返回手势
    self.interactivePopGestureRecognizer.delegate = self;
    self.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return self.viewControllers.count > 1;
    }
    return YES;
}

#pragma mark - 状态栏样式

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
