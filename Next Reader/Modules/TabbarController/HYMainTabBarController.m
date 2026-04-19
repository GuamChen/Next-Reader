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

@interface HYMainTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, strong) HYCustomTabBarView *customTabBarView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *customTabItems;

@end

@implementation HYMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;
    [self setupChildViewControllers];
    [self setupTabBarAppearance];
    [self setupCustomTabBar];
    [self.customTabBarView setSelectedIndex:self.selectedIndex animated:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tabBar.clipsToBounds = NO;
    self.tabBar.layer.masksToBounds = NO;

    CGFloat customHeight = CGRectGetHeight(self.tabBar.bounds) + HYCustomTabBarFloatingHeight;
    self.customTabBarView.frame = CGRectMake(0.0f,
                                             CGRectGetMinY(self.tabBar.frame) - HYCustomTabBarFloatingHeight,
                                             CGRectGetWidth(self.view.bounds),
                                             customHeight);
    self.customTabBarView.safeBottomInset = self.view.safeAreaInsets.bottom;
    [self.customTabBarView setNeedsLayout];
}

- (void)setupTabBarAppearance {
    self.view.backgroundColor = [UIColor hy_colorWithHex:0xEFF2F7];
    self.tabBar.translucent = YES;
    self.tabBar.backgroundImage = [UIImage new];
    self.tabBar.shadowImage = [UIImage new];
    self.tabBar.backgroundColor = UIColor.clearColor;
    self.tabBar.barTintColor = UIColor.clearColor;
    self.tabBar.tintColor = UIColor.clearColor;
    self.tabBar.unselectedItemTintColor = UIColor.clearColor;

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
        strongSelf.selectedIndex = index;
        [strongSelf.customTabBarView setSelectedIndex:index animated:YES];
    };

    [self.view addSubview:self.customTabBarView];
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
    [self.customTabBarView setSelectedIndex:self.selectedIndex animated:YES];
}

@end
