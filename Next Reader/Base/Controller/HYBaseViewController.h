//
//  HYBaseViewController.h
//  极速文档阅读器
//
//  Created by Tencent iOS Team
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 导航栏样式枚举
typedef NS_ENUM(NSInteger, HYNavigationBarStyle) {
    HYNavigationBarStyleDefault = 0,    // 默认白色背景，黑色文字
    HYNavigationBarStyleTransparent,     // 透明背景
    HYNavigationBarStyleGradient,        // 渐变背景
};

/// 返回按钮类型枚举
typedef NS_ENUM(NSInteger, HYBackButtonType) {
    HYBackButtonTypeDefault = 0,    // 默认返回箭头
    HYBackButtonTypeClose,          // 关闭按钮（X）
    HYBackButtonTypeText,           // 文字返回
};

@interface HYBaseViewController : UIViewController

#pragma mark - 导航栏相关属性

/// 自定义导航栏容器
@property (nonatomic, strong, readonly) UIView *hy_navigationBar;

/// 导航栏标题
@property (nonatomic, strong, readonly) UILabel *hy_titleLabel;

/// 左侧按钮
@property (nonatomic, strong, readonly) UIButton *hy_leftButton;

/// 右侧按钮
@property (nonatomic, strong, readonly) UIButton *hy_rightButton;

/// 导航栏底部分割线
@property (nonatomic, strong, readonly) UIView *hy_navSeparatorLine;

/// 导航栏样式
@property (nonatomic, assign) HYNavigationBarStyle hy_navBarStyle;

/// 导航栏背景色（默认白色）
@property (nonatomic, strong) UIColor *hy_navBarBackgroundColor;

/// 导航栏标题颜色（默认黑色）
@property (nonatomic, strong) UIColor *hy_navTitleColor;

/// 是否隐藏导航栏（默认 NO）
@property (nonatomic, assign) BOOL hy_hideNavigationBar;

/// 是否隐藏导航栏分割线（默认 NO）
@property (nonatomic, assign) BOOL hy_hideNavSeparator;

/// 是否启用侧滑返回手势（默认 YES）
@property (nonatomic, assign) BOOL hy_enableSwipeBack;

#pragma mark - 导航栏配置方法

/// 设置导航栏标题
/// @param title 标题文字
- (void)hy_setNavTitle:(NSString *)title;

/// 设置导航栏标题和颜色
/// @param title 标题文字
/// @param color 标题颜色
- (void)hy_setNavTitle:(NSString *)title color:(nullable UIColor *)color;

/// 设置左侧返回按钮
/// @param type 返回按钮类型
- (void)hy_setBackButtonWithType:(HYBackButtonType)type;

/// 设置左侧自定义按钮
/// @param title 按钮标题
/// @param imageName 按钮图片
/// @param target 目标
/// @param action 方法
- (void)hy_setLeftButtonWithTitle:(nullable NSString *)title
                            image:(nullable NSString *)imageName
                           target:(nullable id)target
                           action:(nullable SEL)action;

/// 设置右侧自定义按钮
/// @param title 按钮标题
/// @param imageName 按钮图片
/// @param target 目标
/// @param action 方法
- (void)hy_setRightButtonWithTitle:(nullable NSString *)title
                             image:(nullable NSString *)imageName
                            target:(nullable id)target
                            action:(nullable SEL)action;

/// 隐藏左侧按钮
- (void)hy_hideLeftButton;

/// 隐藏右侧按钮
- (void)hy_hideRightButton;


// 内容容器
@property (nonatomic, strong, readonly) UIView *hy_contentView;


#pragma mark - 公共功能方法



/// 显示加载中（默认文案："加载中..."）
- (void)hy_showLoading;

/// 显示加载中（自定义文案）
/// @param message 加载文案
- (void)hy_showLoadingWithMessage:(nullable NSString *)message;

/// 隐藏加载中
- (void)hy_hideLoading;

/// 显示 Toast 提示（自动消失）
/// @param text 提示文字
- (void)hy_showToast:(NSString *)text;

/// 显示 Toast 提示（自定义时长）
/// @param text 提示文字
/// @param duration 显示时长（秒）
- (void)hy_showToast:(NSString *)text duration:(NSTimeInterval)duration;

/// 显示空状态页面
/// @param imageName 空状态图片
/// @param title 标题
/// @param message 描述文字
- (void)hy_showEmptyViewWithImage:(nullable NSString *)imageName
                            title:(nullable NSString *)title
                          message:(nullable NSString *)message;

/// 隐藏空状态页面
- (void)hy_hideEmptyView;

/// 显示网络错误页面（带重试按钮）
/// @param retryBlock 重试回调
- (void)hy_showNetworkErrorViewWithRetryBlock:(void(^)(void))retryBlock;

#pragma mark - 子类可重写的方法

/// 左侧按钮点击事件（默认实现：返回上一页）
- (void)hy_leftButtonAction:(UIButton *)sender;

/// 右侧按钮点击事件（子类重写实现）
- (void)hy_rightButtonAction:(UIButton *)sender;

/// 自定义导航栏布局（子类重写时需调用 super）
- (void)hy_setupNavigationBar;

/// 自定义内容布局（子类重写时需调用 super）
- (void)hy_setupContentView;

#pragma mark - 生命周期相关

/// 视图即将可见时调用（用于统计等）
- (void)hy_viewWillAppearForFirstTime;

@end

NS_ASSUME_NONNULL_END
