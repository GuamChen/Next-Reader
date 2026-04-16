//
//  UIColor.h
//  Next Reader
//
//  Created by Gavin on 2026/4/17.
//


//
//  UIColor+HYExtension.h
//  极速文档阅读器
//
//  Created by Tencent iOS Team
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (HYExtension)

/// 通过十六进制字符串创建颜色
/// @param hexString 十六进制字符串（支持格式：#RGB, #ARGB, #RRGGBB, #AARRGGBB）
+ (UIColor *)hy_colorWithHexString:(NSString *)hexString;

/// 通过十六进制数值创建颜色
/// @param hex 十六进制数值（0xRRGGBB）
+ (UIColor *)hy_colorWithHex:(NSInteger)hex;

/// 通过十六进制数值和透明度创建颜色
/// @param hex 十六进制数值（0xRRGGBB）
/// @param alpha 透明度（0.0 ~ 1.0）
+ (UIColor *)hy_colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;

/// 通过RGB值创建颜色（0-255）
/// @param red 红色值
/// @param green 绿色值
/// @param blue 蓝色值
+ (UIColor *)hy_colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue;

/// 通过RGB和透明度创建颜色（0-255）
/// @param red 红色值
/// @param green 绿色值
/// @param blue 蓝色值
/// @param alpha 透明度
+ (UIColor *)hy_colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue alpha:(CGFloat)alpha;

/// 生成随机颜色
+ (UIColor *)hy_randomColor;

/// 获取颜色的十六进制字符串（格式：#RRGGBB）
- (NSString *)hy_hexString;

/// 获取颜色的RGB分量
- (void)hy_getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;

/// 颜色渐变（从起始色到结束色）
/// @param fromColor 起始颜色
/// @param toColor 结束颜色
/// @param progress 进度（0.0 ~ 1.0）
+ (UIColor *)hy_gradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress;

/// 颜色变亮
/// @param percent 亮度百分比（0.0 ~ 1.0）
- (UIColor *)hy_lighten:(CGFloat)percent;

/// 颜色变暗
/// @param percent 暗度百分比（0.0 ~ 1.0）
- (UIColor *)hy_darken:(CGFloat)percent;

@end

NS_ASSUME_NONNULL_END
