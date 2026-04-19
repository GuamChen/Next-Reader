//
//  HYUIConstants.h
//  极速文档阅读器
//
//  Created by Tencent iOS Team
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// ==================== 颜色定义 ====================
#pragma mark - 颜色定义

// 主题色
#define HY_COLOR_THEME              [UIColor hy_colorWithHex:0x0052D9]  // 腾讯蓝
#define HY_COLOR_THEME_LIGHT        [UIColor hy_colorWithHex:0x366EF4]
#define HY_COLOR_THEME_DARK         [UIColor hy_colorWithHex:0x003CAB]

// 背景色
#define HY_COLOR_BG_WHITE           [UIColor hy_colorWithHex:0xFFFFFF]
#define HY_COLOR_BG_GRAY            [UIColor hy_colorWithHex:0xF5F5F5]
#define HY_COLOR_BG_LIGHT_GRAY      [UIColor hy_colorWithHex:0xFAFAFA]
#define HY_COLOR_BG_DARK            [UIColor hy_colorWithHex:0x1A1A1A]

// 文字颜色
#define HY_COLOR_TEXT_PRIMARY       [UIColor hy_colorWithHex:0x1A1A1A]  // 主要文字
#define HY_COLOR_TEXT_SECONDARY     [UIColor hy_colorWithHex:0x666666]  // 次要文字
#define HY_COLOR_TEXT_TERTIARY      [UIColor hy_colorWithHex:0x999999]  // 辅助文字
#define HY_COLOR_TEXT_DISABLED      [UIColor hy_colorWithHex:0xCCCCCC]  // 禁用文字
#define HY_COLOR_TEXT_LINK          [UIColor hy_colorWithHex:0x0052D9]  // 链接文字

// 分割线颜色
#define HY_COLOR_SEPARATOR          [UIColor hy_colorWithHex:0xEEEEEE]
#define HY_COLOR_SEPARATOR_DARK     [UIColor hy_colorWithHex:0xE5E5E5]

// 功能色
#define HY_COLOR_SUCCESS            [UIColor hy_colorWithHex:0x00A870]  // 成功绿
#define HY_COLOR_WARNING            [UIColor hy_colorWithHex:0xED7B2F]  // 警告橙
#define HY_COLOR_ERROR              [UIColor hy_colorWithHex:0xE34D59]  // 错误红
#define HY_COLOR_INFO               [UIColor hy_colorWithHex:0x0052D9]  // 信息蓝

// 遮罩色
#define HY_COLOR_MASK_BLACK         [UIColor hy_colorWithHex:0x000000 alpha:0.5]
#define HY_COLOR_MASK_LIGHT         [UIColor hy_colorWithHex:0x000000 alpha:0.3]

// ==================== 字体定义 ====================
#pragma mark - 字体定义

#define HY_FONT(size)               [UIFont systemFontOfSize:size]
#define HY_FONT_BOLD(size)          [UIFont boldSystemFontOfSize:size]
#define HY_FONT_MEDIUM(size)        [UIFont systemFontOfSize:size weight:UIFontWeightMedium]
#define HY_FONT_LIGHT(size)         [UIFont systemFontOfSize:size weight:UIFontWeightLight]

// 预设字号
#define HY_FONT_SIZE_H1             24.0f  // 大标题
#define HY_FONT_SIZE_H2             20.0f  // 标题
#define HY_FONT_SIZE_H3             18.0f  // 子标题
#define HY_FONT_SIZE_BODY           16.0f  // 正文
#define HY_FONT_SIZE_CAPTION        14.0f  // 说明文字
#define HY_FONT_SIZE_SMALL          12.0f  // 辅助文字

// 预设字体
#define HY_FONT_H1                  HY_FONT_BOLD(HY_FONT_SIZE_H1)
#define HY_FONT_H2                  HY_FONT_MEDIUM(HY_FONT_SIZE_H2)
#define HY_FONT_H3                  HY_FONT_MEDIUM(HY_FONT_SIZE_H3)
#define HY_FONT_BODY                HY_FONT(HY_FONT_SIZE_BODY)
#define HY_FONT_CAPTION             HY_FONT(HY_FONT_SIZE_CAPTION)
#define HY_FONT_SMALL               HY_FONT(HY_FONT_SIZE_SMALL)

// ==================== 间距定义 ====================
#pragma mark - 间距定义

#define HY_MARGIN_XXS               4.0f
#define HY_MARGIN_XS                8.0f
#define HY_MARGIN_SM                12.0f
#define HY_MARGIN_MD                16.0f
#define HY_MARGIN_LG                20.0f
#define HY_MARGIN_XL                24.0f
#define HY_MARGIN_XXL               32.0f

// ==================== 圆角定义 ====================
#pragma mark - 圆角定义

#define HY_CORNER_RADIUS_SM          4.0f
#define HY_CORNER_RADIUS_MD          8.0f
#define HY_CORNER_RADIUS_LG          12.0f
#define HY_CORNER_RADIUS_XL          16.0f
#define HY_CORNER_RADIUS_ROUND       (CGFLOAT_MAX / 2.0f)

// ==================== 阴影定义 ====================
#pragma mark - 阴影定义

#define HY_SHADOW_OFFSET_DEFAULT    CGSizeMake(0, 2)
#define HY_SHADOW_RADIUS_DEFAULT    8.0f
#define HY_SHADOW_OPACITY_DEFAULT   0.08f

// ==================== 动画时长 ====================
#pragma mark - 动画时长

#define HY_ANIMATION_DURATION_FAST  0.15f
#define HY_ANIMATION_DURATION_NORMAL 0.25f
#define HY_ANIMATION_DURATION_SLOW  0.35f

// ==================== 屏幕尺寸 ====================
#pragma mark - 屏幕尺寸

#define HY_SCREEN_WIDTH             [UIScreen mainScreen].bounds.size.width
#define HY_SCREEN_HEIGHT            [UIScreen mainScreen].bounds.size.height
#define HY_SCREEN_BOUNDS            [UIScreen mainScreen].bounds

#define HY_KEY_WINDOW               ({\
    UIWindow *hy_window = nil;\
    if (@available(iOS 13.0, *)) {\
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {\
            if (![scene isKindOfClass:[UIWindowScene class]]) {\
                continue;\
            }\
            UIWindowScene *windowScene = (UIWindowScene *)scene;\
            for (UIWindow *window in windowScene.windows) {\
                if (window.isKeyWindow) {\
                    hy_window = window;\
                    break;\
                }\
            }\
            if (hy_window) {\
                break;\
            }\
        }\
    }\
    if (!hy_window) {\
        hy_window = [UIApplication sharedApplication].keyWindow;\
    }\
    if (!hy_window && [UIApplication sharedApplication].windows.count > 0) {\
        hy_window = [UIApplication sharedApplication].windows.firstObject;\
    }\
    hy_window;\
})

#define HY_IS_IPHONE_X              ({\
    BOOL isPhoneX = NO;\
    if (@available(iOS 11.0, *)) {\
        UIWindow *window = HY_KEY_WINDOW;\
        isPhoneX = window.safeAreaInsets.bottom > 0.0f;\
    }\
    isPhoneX;\
})

#define HY_STATUS_BAR_HEIGHT        (HY_IS_IPHONE_X ? 44.0f : 20.0f)
#define HY_NAV_BAR_HEIGHT           44.0f
#define HY_TAB_BAR_HEIGHT           (HY_IS_IPHONE_X ? 83.0f : 49.0f)
#define HY_SAFE_BOTTOM_MARGIN       (HY_IS_IPHONE_X ? 34.0f : 0.0f)

// ==================== 单例定义 ====================
#pragma mark - 单例定义

#define HY_SINGLETON_H(name) + (instancetype)shared##name;

#define HY_SINGLETON_M(name) \
+ (instancetype)shared##name { \
    static dispatch_once_t onceToken; \
    static id instance = nil; \
    dispatch_once(&onceToken, ^{ \
        instance = [[self alloc] init]; \
    }); \
    return instance; \
}

// ==================== 弱引用/强引用 ====================
#pragma mark - 弱引用/强引用

#define HY_WEAK_SELF        __weak typeof(self) weakSelf = self;
#define HY_STRONG_SELF      __strong typeof(weakSelf) strongSelf = weakSelf;

#define HY_WEAK_OBJ(obj)    __weak typeof(obj) weak##obj = obj;
#define HY_STRONG_OBJ(obj)  __strong typeof(weak##obj) strong##obj = weak##obj;

// ==================== 日志宏 ====================
#pragma mark - 日志宏

#ifdef DEBUG
    #define HYLog(...) NSLog(@"%s 第%d行 \n %@\n\n", __func__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
    #define HYLogFunc HYLog(@"%s", __func__)
    #define HYLogError(error) HYLog(@"Error: %@", error)
#else
    #define HYLog(...)
    #define HYLogFunc
    #define HYLogError(error)
#endif

// ==================== 字符串常量 ====================
#pragma mark - 字符串常量

#define HY_STRING_EMPTY             @""
#define HY_STRING_SPACE             @" "
#define HY_STRING_ELLIPSIS          @"..."

// ==================== 系统版本判断 ====================
#pragma mark - 系统版本判断

#define HY_SYSTEM_VERSION           [[UIDevice currentDevice] systemVersion].floatValue
#define HY_IS_IOS_12_OR_LATER       (HY_SYSTEM_VERSION >= 12.0)
#define HY_IS_IOS_13_OR_LATER       (HY_SYSTEM_VERSION >= 13.0)
#define HY_IS_IOS_14_OR_LATER       (HY_SYSTEM_VERSION >= 14.0)

// ==================== 图片加载 ====================
#pragma mark - 图片加载

#define HY_IMAGE(name)              [UIImage imageNamed:name]
#define HY_IMAGE_ORIGINAL(name)    [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]



// ==================== 检查判断 ====================

#define HY_STRING_IS_EMPTY(str) \
    (!(str) || \
     [(str) isKindOfClass:[NSNull class]] || \
     [(str) length] == 0 || \
     [[(str) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)

@interface HYUIBuildFactory : NSObject

+ (UIView *)viewWithBackgroundColor:(nullable UIColor *)backgroundColor;
+ (UIView *)separatorLineWithColor:(nullable UIColor *)color;

+ (UILabel *)labelWithFont:(UIFont *)font
                 textColor:(UIColor *)textColor
                 alignment:(NSTextAlignment)alignment;

+ (UIButton *)buttonWithTitle:(nullable NSString *)title
                   titleColor:(nullable UIColor *)titleColor
                         font:(nullable UIFont *)font
                       target:(nullable id)target
                       action:(nullable SEL)action;

@end
