//
//  UIColor.m
//  Next Reader
//
//  Created by Gavin on 2026/4/17.
//


//
//  UIColor+HYExtension.m
//  极速文档阅读器
//
//  Created by Tencent iOS Team
//

#import "UIColor+HYExtension.h"

@implementation UIColor (HYExtension)

#pragma mark - 十六进制字符串转颜色

+ (UIColor *)hy_colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    
    CGFloat alpha = 1.0f;
    CGFloat red = 0.0f;
    CGFloat green = 0.0f;
    CGFloat blue = 0.0f;
    
    switch (colorString.length) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self hy_colorComponentFrom:colorString start:0 length:1];
            green = [self hy_colorComponentFrom:colorString start:1 length:1];
            blue  = [self hy_colorComponentFrom:colorString start:2 length:1];
            break;
            
        case 4: // #ARGB
            alpha = [self hy_colorComponentFrom:colorString start:0 length:1];
            red   = [self hy_colorComponentFrom:colorString start:1 length:1];
            green = [self hy_colorComponentFrom:colorString start:2 length:1];
            blue  = [self hy_colorComponentFrom:colorString start:3 length:1];
            break;
            
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self hy_colorComponentFrom:colorString start:0 length:2];
            green = [self hy_colorComponentFrom:colorString start:2 length:2];
            blue  = [self hy_colorComponentFrom:colorString start:4 length:2];
            break;
            
        case 8: // #AARRGGBB
            alpha = [self hy_colorComponentFrom:colorString start:0 length:2];
            red   = [self hy_colorComponentFrom:colorString start:2 length:2];
            green = [self hy_colorComponentFrom:colorString start:4 length:2];
            blue  = [self hy_colorComponentFrom:colorString start:6 length:2];
            break;
            
        default:
            [NSException raise:@"Invalid hex string" format:@"Hex string %@ is invalid", hexString];
            break;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)hy_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0f;
}

#pragma mark - 十六进制数值转颜色

+ (UIColor *)hy_colorWithHex:(NSInteger)hex {
    return [self hy_colorWithHex:hex alpha:1.0f];
}

+ (UIColor *)hy_colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha {
    CGFloat red   = ((hex & 0xFF0000) >> 16) / 255.0f;
    CGFloat green = ((hex & 0x00FF00) >> 8)  / 255.0f;
    CGFloat blue  = (hex & 0x0000FF)         / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - RGB值创建颜色

+ (UIColor *)hy_colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue {
    return [self hy_colorWithR:red G:green B:blue alpha:1.0f];
}

+ (UIColor *)hy_colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

#pragma mark - 随机颜色

+ (UIColor *)hy_randomColor {
    CGFloat red   = arc4random_uniform(256) / 255.0f;
    CGFloat green = arc4random_uniform(256) / 255.0f;
    CGFloat blue  = arc4random_uniform(256) / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

#pragma mark - 获取十六进制字符串

- (NSString *)hy_hexString {
    CGFloat red = 0.0f;
    CGFloat green = 0.0f;
    CGFloat blue = 0.0f;
    CGFloat alpha = 0.0f;
    
    [self hy_getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSInteger rgb = (NSInteger)(red * 255) << 16 | (NSInteger)(green * 255) << 8 | (NSInteger)(blue * 255);
    return [NSString stringWithFormat:@"#%06lx", (long)rgb];
}

#pragma mark - 获取RGB分量

- (void)hy_getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    size_t numberOfComponents = CGColorGetNumberOfComponents(self.CGColor);
    
    if (numberOfComponents == 2) { // 灰度颜色
        if (red) *red = components[0];
        if (green) *green = components[0];
        if (blue) *blue = components[0];
        if (alpha) *alpha = components[1];
    } else if (numberOfComponents == 4) { // RGB颜色
        if (red) *red = components[0];
        if (green) *green = components[1];
        if (blue) *blue = components[2];
        if (alpha) *alpha = components[3];
    } else {
        // 默认值
        if (red) *red = 0.0f;
        if (green) *green = 0.0f;
        if (blue) *blue = 0.0f;
        if (alpha) *alpha = 1.0f;
    }
}

#pragma mark - 颜色渐变

+ (UIColor *)hy_gradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress {
    progress = MIN(1.0f, MAX(0.0f, progress));
    
    CGFloat fromRed = 0.0f, fromGreen = 0.0f, fromBlue = 0.0f, fromAlpha = 0.0f;
    CGFloat toRed = 0.0f, toGreen = 0.0f, toBlue = 0.0f, toAlpha = 0.0f;
    
    [fromColor hy_getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    [toColor hy_getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat red   = fromRed   + (toRed   - fromRed)   * progress;
    CGFloat green = fromGreen + (toGreen - fromGreen) * progress;
    CGFloat blue  = fromBlue  + (toBlue  - fromBlue)  * progress;
    CGFloat alpha = fromAlpha + (toAlpha - fromAlpha) * progress;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - 颜色亮度调整

- (UIColor *)hy_lighten:(CGFloat)percent {
    return [self hy_adjustBrightness:percent];
}

- (UIColor *)hy_darken:(CGFloat)percent {
    return [self hy_adjustBrightness:-percent];
}

- (UIColor *)hy_adjustBrightness:(CGFloat)percent {
    CGFloat red = 0.0f, green = 0.0f, blue = 0.0f, alpha = 0.0f;
    [self hy_getRed:&red green:&green blue:&blue alpha:&alpha];
    
    red   = MIN(1.0f, MAX(0.0f, red   + percent));
    green = MIN(1.0f, MAX(0.0f, green + percent));
    blue  = MIN(1.0f, MAX(0.0f, blue  + percent));
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end