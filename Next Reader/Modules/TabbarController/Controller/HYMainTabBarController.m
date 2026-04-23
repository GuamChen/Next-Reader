//
//  HYMainTabBarController.m
//  极速文档阅读器
//
//  Created by Tencent iOS Team
//

#import "HYMainTabBarController.h"

#import "HYBaseNavigationController.h"
#import "HYDocumentListViewController.h"
#import "HYSettingViewController.h"
#import "HYTabPlaceholderViewController.h"
#import "HYCustomTabBarBackgroundView.h"
#import "HYCustomTabBarItemView.h"
#import "HYCustomTabBarView.h"

@interface HYMainTabBarController () <UITabBarControllerDelegate,UINavigationControllerDelegate>

// 自定义 tabbar 只负责 UI 展示，真正的页面切换仍然由 UITabBarController 维护。
@property (nonatomic, strong) HYCustomTabBarView *customTabBarView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *customTabItems;

@end

@implementation HYMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;
    // 先准备页面，再把系统 tabbar 变透明，最后叠加自定义 tabbar。
    [self setupChildViewControllers];
    [self setupTabBarAppearance];
    [self setupCustomTabBar];
    [self.customTabBarView setSelectedIndex:self.selectedIndex animated:NO];
    
    for (UIViewController *vc in self.viewControllers) {
            if ([vc isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController *)vc;
                nav.delegate = self;
            }
        }
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tabBar.clipsToBounds = NO;
    self.tabBar.layer.masksToBounds = NO;
    // 系统 tabBar 的按钮仍然存在，这里只保留它的容器能力，把默认按钮隐藏掉。
    for (UIView *subview in self.tabBar.subviews) {
        if ([subview isKindOfClass:UIControl.class]) {
            subview.hidden = YES;
        }
    }
    
    // 自定义 tabbar 比系统 tabbar 更高，因为需要给上浮按钮预留可见空间。
    CGFloat customHeight = CGRectGetHeight(self.tabBar.bounds) + HYCustomTabBarFloatingHeight;
    self.customTabBarView.frame = CGRectMake(0.0f,
                                             CGRectGetMinY(self.tabBar.frame) - HYCustomTabBarFloatingHeight,
                                             CGRectGetWidth(self.view.bounds),
                                             customHeight);
    self.customTabBarView.safeBottomInset = self.view.safeAreaInsets.bottom;
    [self.customTabBarView setNeedsLayout];
    [self.view bringSubviewToFront:self.customTabBarView];
}

- (void)setupTabBarAppearance {
    self.view.backgroundColor = [UIColor hy_colorWithHex:0xEFF2F7];
    // 系统 tabBar 不再承担任何视觉职责，所有视觉由 HYCustomTabBarView 绘制。
    self.tabBar.translucent = YES;
    self.tabBar.backgroundImage = [UIImage new];
    self.tabBar.shadowImage = [UIImage new];
    self.tabBar.backgroundColor = UIColor.clearColor;
    self.tabBar.barTintColor = UIColor.clearColor;
    self.tabBar.tintColor = UIColor.clearColor;
    self.tabBar.unselectedItemTintColor = UIColor.clearColor;
    self.tabBar.opaque = NO;

    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithTransparentBackground];
        appearance.backgroundColor = UIColor.clearColor;

        UITabBarItemAppearance *stackedAppearance = appearance.stackedLayoutAppearance;
        stackedAppearance.normal.iconColor = UIColor.clearColor;
        stackedAppearance.selected.iconColor = UIColor.clearColor;
        stackedAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.clearColor};
        stackedAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.clearColor};

        appearance.inlineLayoutAppearance.normal.iconColor = UIColor.clearColor;
        appearance.inlineLayoutAppearance.selected.iconColor = UIColor.clearColor;
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.clearColor};
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.clearColor};

        appearance.compactInlineLayoutAppearance.normal.iconColor = UIColor.clearColor;
        appearance.compactInlineLayoutAppearance.selected.iconColor = UIColor.clearColor;
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.clearColor};
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.clearColor};

        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    }
}

- (void)setupChildViewControllers {
    UIImage *clearImage = [self hy_clearTabBarImage];

    HYDocumentListViewController *documentVC = [[HYDocumentListViewController alloc] init];
    HYBaseNavigationController *documentNav = [[HYBaseNavigationController alloc] initWithRootViewController:documentVC];
    documentNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:clearImage selectedImage:clearImage];

    HYTabPlaceholderViewController *placeholderVC = [[HYTabPlaceholderViewController alloc] init];
    placeholderVC.title = @"viewcontroller";
    HYBaseNavigationController *placeholderNav = [[HYBaseNavigationController alloc] initWithRootViewController:placeholderVC];
    placeholderNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:clearImage selectedImage:clearImage];

    HYSettingViewController *settingsVC = [[HYSettingViewController alloc] init];
    HYBaseNavigationController *settingsNav = [[HYBaseNavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:clearImage selectedImage:clearImage];

    self.viewControllers = @[documentNav, placeholderNav, settingsNav];

    // 自定义 tabbar 的 item 数据源。controller 和 item 视觉故意分开，避免把业务和 UI 写死在一起。
    self.customTabItems = @[
        @{@"title": @"文档",
          @"normalImage": [self hy_tabBarIconNamed:@"tab_document_normal" systemName:@"doc.text"],
          @"selectedImage": [self hy_tabBarIconNamed:@"tab_document_selected" systemName:@"doc.text.fill"]},
        @{@"title": @"viewcontroller",
          @"normalImage": [self hy_tabBarIconNamed:nil systemName:@"square.stack.3d.up"],
          @"selectedImage": [self hy_tabBarIconNamed:nil systemName:@"square.stack.3d.up.fill"]},
        @{@"title": @"我的",
          @"normalImage": [self hy_tabBarIconNamed:@"tab_settings_normal" systemName:@"person"],
          @"selectedImage": [self hy_tabBarIconNamed:@"tab_settings_selected" systemName:@"person.fill"]},
    ];
}

- (void)setupCustomTabBar {
    self.customTabBarView = [[HYCustomTabBarView alloc] init];
    [self.customTabBarView configureWithItems:self.customTabItems];

    HY_WEAK_SELF
    self.customTabBarView.selectionHandler = ^(NSInteger index) {
        HY_STRONG_SELF
        if (!strongSelf || index >= strongSelf.viewControllers.count) {
            return;
        }
        // 点击自定义 item 后，只改 selectedIndex；
        // UITabBarController 会接管页面切换，UI 状态再同步回自定义 tabbar。
        strongSelf.selectedIndex = index;
        [strongSelf.customTabBarView setSelectedIndex:index animated:YES];
    };

    [self.view addSubview:self.customTabBarView];
//    [self.tabBar addSubview:self.customTabBarView];
}

- (UIImage *)hy_tabBarIconNamed:(NSString *)assetName systemName:(NSString *)systemName {
    UIImage *image = nil;
    if (!HY_STRING_IS_EMPTY(assetName)) {
        image = HY_IMAGE_ORIGINAL(assetName);
    }
    if (image != nil) {
        return image;
    }
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:22.0f weight:UIImageSymbolWeightRegular];
        return [[UIImage systemImageNamed:systemName] imageWithConfiguration:configuration];
    }
    return [UIImage new];
}

- (UIImage *)hy_clearTabBarImage {
    static UIImage *clearImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0f, 1.0f), NO, 0.0f);
        clearImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return clearImage;
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // 兜底同步：无论是点击自定义 tab，还是外部代码修改 selectedIndex，都统一刷新 UI 状态。
    [self.customTabBarView setSelectedIndex:self.selectedIndex animated:YES];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    // 检查即将显示的 viewController 是否设置了 hidesBottomBarWhenPushed
    BOOL shouldHideTabBar = viewController.hidesBottomBarWhenPushed;
    
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
        self.customTabBarView.alpha = shouldHideTabBar ? 0.0f : 1.0f;
    } completion:^(BOOL finished) {
        self.customTabBarView.hidden = shouldHideTabBar;
    }];
}

@end
