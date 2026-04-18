//
//  HYMainTabBarController.m
//  极速文档阅读器
//
//  Created by Tencent iOS Team
//

#import "HYMainTabBarController.h"
#import "HYDocumentListViewController.h"
#import "HYSettingViewController.h"
#import "HYBaseNavigationController.h"

@interface HYMainTabBarController ()

@end

@implementation HYMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTabBarAppearance];
    [self setupChildViewControllers];
}

- (void)setupTabBarAppearance {
    // 配置 TabBar 样式
    self.tabBar.backgroundColor = HY_COLOR_BG_WHITE;
    self.tabBar.tintColor = HY_COLOR_THEME;
    
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = HY_COLOR_BG_WHITE;
        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    }
    
    // 移除顶部分割线
    self.tabBar.shadowImage = [[UIImage alloc] init];
    self.tabBar.backgroundImage = [[UIImage alloc] init];
}

- (void)setupChildViewControllers {
    // 文档列表
    HYDocumentListViewController *documentVC = [[HYDocumentListViewController alloc] init];
    HYBaseNavigationController *documentNav = [[HYBaseNavigationController alloc] initWithRootViewController:documentVC];
    documentNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"文档"
                                                           image:[self hy_tabBarImageNamed:@"tab_document_normal" systemName:@"doc.text"]
                                                   selectedImage:[self hy_tabBarImageNamed:@"tab_document_selected" systemName:@"doc.text.fill"]];
    
    
    // 设置
    HYSettingViewController *settingsVC = [[HYSettingViewController alloc] init];
    HYBaseNavigationController *settingsNav = [[HYBaseNavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的"
                                                           image:[self hy_tabBarImageNamed:@"tab_settings_normal" systemName:@"person"]
                                                   selectedImage:[self hy_tabBarImageNamed:@"tab_settings_selected" systemName:@"person.fill"]];
    
    self.viewControllers = @[documentNav, settingsNav];
}

- (UIImage *)hy_tabBarImageNamed:(NSString *)assetName systemName:(NSString *)systemName {
    UIImage *image = HY_IMAGE_ORIGINAL(assetName);
    if (image) {
        return image;
    }

    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:systemName];
    }

    return nil;
}

@end
