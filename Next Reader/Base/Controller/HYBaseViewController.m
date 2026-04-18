//
//  HYBaseViewController.m
//  极速文档阅读器
//
//  Created by Tencent iOS Team
//

#import "HYBaseViewController.h"

#import "HYEmptyView.h"
#import "HYLoadingView.h"
#import "HYToastView.h"

#import <objc/runtime.h>

// ==================== HYBaseViewController 私有接口 ====================
@interface HYBaseViewController () <UIGestureRecognizerDelegate>

// 导航栏相关
@property (nonatomic, strong, readwrite) UIView *hy_navigationBar;
@property (nonatomic, strong, readwrite) UILabel *hy_titleLabel;
@property (nonatomic, strong, readwrite) UIButton *hy_leftButton;
@property (nonatomic, strong, readwrite) UIButton *hy_rightButton;
@property (nonatomic, strong, readwrite) UIView *hy_navSeparatorLine;

// 内容容器
@property (nonatomic, strong, readwrite) UIView *hy_contentView;

// Loading & Toast & Empty
@property (nonatomic, strong) HYLoadingView *loadingView;
@property (nonatomic, strong) HYEmptyView *emptyView;

// 状态标记
@property (nonatomic, assign) BOOL hy_isFirstAppear;
@property (nonatomic, assign) BOOL hy_hasSetupConstraints;

@end

@implementation HYBaseViewController

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self hy_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self hy_commonInit];
    }
    return self;
}

- (void)hy_commonInit {
    _hy_isFirstAppear = YES;
    _hy_enableSwipeBack = YES;
    _hy_hideNavigationBar = NO;
    _hy_hideNavSeparator = NO;
    _hy_navBarStyle = HYNavigationBarStyleDefault;
    _hy_navBarBackgroundColor = HY_COLOR_BG_WHITE;
    _hy_navTitleColor = HY_COLOR_TEXT_PRIMARY;
    _hy_hasSetupConstraints = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 基础配置
    self.view.backgroundColor = HY_COLOR_BG_WHITE;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    // 设置导航栏
    [self hy_setupNavigationBar];
    
    // 设置内容视图
    [self hy_setupContentView];
    
    // 设置手势
    [self hy_setupGestures];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏系统导航栏
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self hy_updateBackButtonIfNeeded];
    
    // 首次出现回调
    if (self.hy_isFirstAppear) {
        self.hy_isFirstAppear = NO;
        [self hy_viewWillAppearForFirstTime];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 启用/禁用侧滑返回手势
    if (self.navigationController.interactivePopGestureRecognizer) {
        self.navigationController.interactivePopGestureRecognizer.enabled = self.hy_enableSwipeBack;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 隐藏 Toast
//    [HYToastView showInView:nil text:nil duration:0];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    HYLog(@"%@ dealloc", NSStringFromClass([self class]));
}

#pragma mark - UI Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.hy_navBarStyle == HYNavigationBarStyleDefault) {
        if (@available(iOS 13.0, *)) {
            return UIStatusBarStyleDarkContent;
        }
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleDefault;
}

#pragma mark - 导航栏设置

- (void)hy_setupNavigationBar {
    if (self.hy_hideNavigationBar) {
        return;
    }
    
    // 创建导航栏容器
    self.hy_navigationBar = [[UIView alloc] init];
    self.hy_navigationBar.backgroundColor = self.hy_navBarBackgroundColor;
    [self.view addSubview:self.hy_navigationBar];
    
    // 创建标题
    self.hy_titleLabel = [[UILabel alloc] init];
    self.hy_titleLabel.font = HY_FONT_MEDIUM(18);
    self.hy_titleLabel.textColor = self.hy_navTitleColor;
    self.hy_titleLabel.textAlignment = NSTextAlignmentCenter;
    self.hy_titleLabel.text = self.title;
    [self.hy_navigationBar addSubview:self.hy_titleLabel];
    
    // 创建左侧按钮
    self.hy_leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hy_leftButton addTarget:self action:@selector(hy_leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.hy_navigationBar addSubview:self.hy_leftButton];
    
    // 创建右侧按钮
    self.hy_rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hy_rightButton addTarget:self action:@selector(hy_rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.hy_navigationBar addSubview:self.hy_rightButton];
    
    // 创建分割线
    self.hy_navSeparatorLine = [[UIView alloc] init];
    self.hy_navSeparatorLine.backgroundColor = HY_COLOR_SEPARATOR;
    self.hy_navSeparatorLine.hidden = self.hy_hideNavSeparator;
    [self.hy_navigationBar addSubview:self.hy_navSeparatorLine];
    
    // 如果是根控制器，不显示返回按钮
    if (self.navigationController.viewControllers.count > 1) {
        [self hy_setBackButtonWithType:HYBackButtonTypeDefault];
    }
}

- (void)hy_setupContentView {
    self.hy_contentView = [[UIView alloc] init];
    self.hy_contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.hy_contentView];
}

- (void)updateViewConstraints {
    if (!self.hy_hasSetupConstraints) {
        self.hy_hasSetupConstraints = YES;
        [self hy_setupConstraints];
    }
    [super updateViewConstraints];
}

- (void)hy_setupConstraints {
    // 导航栏约束
    if (!self.hy_hideNavigationBar) {
        [self.hy_navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.height.mas_equalTo(HY_STATUS_BAR_HEIGHT + HY_NAV_BAR_HEIGHT);
        }];
        
        [self.hy_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.hy_navigationBar);
            make.bottom.equalTo(self.hy_navigationBar).offset(-12);
            make.left.greaterThanOrEqualTo(self.hy_leftButton.mas_right).offset(10);
            make.right.lessThanOrEqualTo(self.hy_rightButton.mas_left).offset(-10);
        }];
        
        [self.hy_leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.hy_navigationBar).offset(HY_MARGIN_MD);
            make.bottom.equalTo(self.hy_navigationBar).offset(-8);
            make.width.height.mas_equalTo(44);
        }];
        
        [self.hy_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.hy_navigationBar).offset(-HY_MARGIN_MD);
            make.bottom.equalTo(self.hy_navigationBar).offset(-8);
            make.width.height.mas_equalTo(44);
        }];
        
        [self.hy_navSeparatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.hy_navigationBar);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    // 内容视图约束
    [self.hy_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (self.hy_hideNavigationBar) {
            make.top.equalTo(self.view);
        } else {
            make.top.equalTo(self.hy_navigationBar.mas_bottom);
        }
    }];
}

#pragma mark - 手势设置

- (void)hy_setupGestures {
    // 添加点击空白收起键盘的手势（可根据需要启用）
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hy_dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)hy_dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - 导航栏配置方法

- (void)hy_setNavTitle:(NSString *)title {
    self.hy_titleLabel.text = title;
}

- (void)hy_setNavTitle:(NSString *)title color:(UIColor *)color {
    self.hy_titleLabel.text = title;
    if (color) {
        self.hy_titleLabel.textColor = color;
    }
}

- (void)hy_setBackButtonWithType:(HYBackButtonType)type {
    NSString *imageName = nil;
    NSString *title = nil;
    
    switch (type) {
        case HYBackButtonTypeDefault:
            imageName = @"nav_back";
            break;
        case HYBackButtonTypeClose:
            imageName = @"nav_close";
            break;
        case HYBackButtonTypeText:
            title = @"返回";
            break;
    }
    
    [self hy_setLeftButtonWithTitle:title image:imageName target:self action:@selector(hy_leftButtonAction:)];
}

- (void)hy_setLeftButtonWithTitle:(NSString *)title
                            image:(NSString *)imageName
                           target:(id)target
                           action:(SEL)action {
    [self.hy_leftButton setImage:nil forState:UIControlStateNormal];
    [self.hy_leftButton setTitle:title forState:UIControlStateNormal];
    [self.hy_leftButton setTitleColor:HY_COLOR_TEXT_PRIMARY forState:UIControlStateNormal];
    self.hy_leftButton.titleLabel.font = HY_FONT(HY_FONT_SIZE_BODY);
    
    if (imageName) {
        UIImage *buttonImage = HY_IMAGE_ORIGINAL(imageName);
        if (!buttonImage) {
            if (@available(iOS 13.0, *)) {
                NSString *systemName = [imageName isEqualToString:@"nav_close"] ? @"xmark" : @"chevron.left";
                buttonImage = [UIImage systemImageNamed:systemName];
            }
        }
        [self.hy_leftButton setImage:buttonImage forState:UIControlStateNormal];
        self.hy_leftButton.tintColor = HY_COLOR_TEXT_PRIMARY;
    }
    
    if (target && action) {
        [self.hy_leftButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.hy_leftButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)hy_setRightButtonWithTitle:(NSString *)title
                             image:(NSString *)imageName
                            target:(id)target
                            action:(SEL)action {
    [self.hy_rightButton setTitle:title forState:UIControlStateNormal];
    [self.hy_rightButton setTitleColor:HY_COLOR_THEME forState:UIControlStateNormal];
    self.hy_rightButton.titleLabel.font = HY_FONT(HY_FONT_SIZE_BODY);
    
    if (imageName) {
        [self.hy_rightButton setImage:HY_IMAGE_ORIGINAL(imageName) forState:UIControlStateNormal];
    }
    
    if (target && action) {
        [self.hy_rightButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.hy_rightButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)hy_hideLeftButton {
    self.hy_leftButton.hidden = YES;
}

- (void)hy_hideRightButton {
    self.hy_rightButton.hidden = YES;
}

- (void)hy_updateBackButtonIfNeeded {
    if (self.hy_hideNavigationBar) {
        return;
    }

    BOOL shouldShowBackButton = self.navigationController.viewControllers.count > 1 || self.presentingViewController != nil;
    if (shouldShowBackButton) {
        [self hy_setBackButtonWithType:HYBackButtonTypeDefault];
        self.hy_leftButton.hidden = NO;
    } else {
        self.hy_leftButton.hidden = YES;
    }
}

#pragma mark - 导航栏样式更新

- (void)setHy_navBarStyle:(HYNavigationBarStyle)hy_navBarStyle {
    _hy_navBarStyle = hy_navBarStyle;
    [self hy_updateNavigationBarStyle];
}

- (void)hy_updateNavigationBarStyle {
    switch (self.hy_navBarStyle) {
        case HYNavigationBarStyleDefault:
            self.hy_navigationBar.backgroundColor = self.hy_navBarBackgroundColor;
            self.hy_titleLabel.textColor = self.hy_navTitleColor;
            break;
            
        case HYNavigationBarStyleTransparent:
            self.hy_navigationBar.backgroundColor = [UIColor clearColor];
            self.hy_titleLabel.textColor = HY_COLOR_BG_WHITE;
            self.hy_navSeparatorLine.hidden = YES;
            break;
            
        case HYNavigationBarStyleGradient:
            // 渐变背景需要子类或具体实现
            break;
    }
}

- (void)setHy_hideNavSeparator:(BOOL)hy_hideNavSeparator {
    _hy_hideNavSeparator = hy_hideNavSeparator;
    self.hy_navSeparatorLine.hidden = hy_hideNavSeparator;
}

#pragma mark - 按钮事件

- (void)hy_leftButtonAction:(UIButton *)sender {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)hy_rightButtonAction:(UIButton *)sender {
    // 子类重写
}

#pragma mark - Loading

- (void)hy_showLoading {
    [self hy_showLoadingWithMessage:@"加载中..."];
}

- (void)hy_showLoadingWithMessage:(NSString *)message {
    if (!self.loadingView) {
        self.loadingView = [[HYLoadingView alloc] init];
    }
    [self.loadingView showInView:self.view message:message];
}

- (void)hy_hideLoading {
    [self.loadingView hide];
}

#pragma mark - Toast

- (void)hy_showToast:(NSString *)text {
    [self hy_showToast:text duration:2.0];
}

- (void)hy_showToast:(NSString *)text duration:(NSTimeInterval)duration {
    if (HY_STRING_IS_EMPTY(text)) {
        return;
    }
    [HYToastView showInView:self.view text:text duration:duration];
}

#pragma mark - Empty View

- (void)hy_showEmptyViewWithImage:(NSString *)imageName
                            title:(NSString *)title
                          message:(NSString *)message {
    if (!self.emptyView) {
        self.emptyView = [[HYEmptyView alloc] init];
    }
    
    if (imageName) {
        self.emptyView.imageView.image = HY_IMAGE(imageName);
    }
    self.emptyView.titleLabel.text = title;
    self.emptyView.messageLabel.text = message;
    self.emptyView.retryButton.hidden = YES;
    
    [self.emptyView showInView:self.hy_contentView];
}

- (void)hy_hideEmptyView {
    [self.emptyView hide];
}

- (void)hy_showNetworkErrorViewWithRetryBlock:(void (^)(void))retryBlock {
    if (!self.emptyView) {
        self.emptyView = [[HYEmptyView alloc] init];
    }
    
    self.emptyView.imageView.image = HY_IMAGE(@"empty_network");
    self.emptyView.titleLabel.text = @"网络连接失败";
    self.emptyView.messageLabel.text = @"请检查网络设置后重试";
    self.emptyView.retryButton.hidden = NO;
    self.emptyView.retryBlock = retryBlock;
    
    [self.emptyView showInView:self.hy_contentView];
}

#pragma mark - 生命周期回调

- (void)hy_viewWillAppearForFirstTime {
    // 子类重写，用于首次加载时的统计或初始化
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return self.navigationController.viewControllers.count > 1 && self.hy_enableSwipeBack;
    }
    return YES;
}

@end
