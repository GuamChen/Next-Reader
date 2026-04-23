#import "HYFontManager.h"

#import <float.h>

NSString * const HYFontSizeDidChangeNotification = @"HYFontSizeDidChangeNotification";

static NSString * const HYFontScaleDefaultsKey = @"com.nextreader.ui.font.scale";

@interface HYFontManager ()

@property (nonatomic, assign, readwrite) CGFloat currentScale;
@property (nonatomic, strong) NSArray<NSNumber *> *cachedSupportedScales;

@end

@implementation HYFontManager

+ (instancetype)sharedManager {
    static HYFontManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cachedSupportedScales = @[@0.9f, @1.0f, @1.1f, @1.2f];
        CGFloat savedScale = [[NSUserDefaults standardUserDefaults] floatForKey:HYFontScaleDefaultsKey];
        _currentScale = [self closestSupportedScaleForScale:(savedScale > 0.0f ? savedScale : 1.0f)];
    }
    return self;
}

- (void)saveFontScale:(CGFloat)fontScale {
    CGFloat targetScale = [self closestSupportedScaleForScale:fontScale];
    if (fabs(self.currentScale - targetScale) < DBL_EPSILON) {
        return;
    }

    self.currentScale = targetScale;
    [[NSUserDefaults standardUserDefaults] setFloat:targetScale forKey:HYFontScaleDefaultsKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:HYFontSizeDidChangeNotification
                                                        object:self
                                                      userInfo:@{@"scale": @(targetScale)}];
}

- (CGFloat)closestSupportedScaleForScale:(CGFloat)fontScale {
    CGFloat resolvedScale = self.cachedSupportedScales.firstObject.floatValue;
    CGFloat minDelta = CGFLOAT_MAX;
    for (NSNumber *number in self.cachedSupportedScales) {
        CGFloat supportedScale = number.floatValue;
        CGFloat delta = fabs(supportedScale - fontScale);
        if (delta < minDelta) {
            minDelta = delta;
            resolvedScale = supportedScale;
        }
    }
    return resolvedScale;
}

- (UIFont *)scaledFontFromBaseFont:(UIFont *)baseFont {
    if (baseFont == nil) {
        return nil;
    }
    return [UIFont fontWithDescriptor:baseFont.fontDescriptor size:baseFont.pointSize * self.currentScale];
}

- (NSString *)displayTitleForScale:(CGFloat)fontScale {
    CGFloat resolvedScale = [self closestSupportedScaleForScale:fontScale];
    if (fabs(resolvedScale - 0.9f) < DBL_EPSILON) {
        return @"小";
    }
    if (fabs(resolvedScale - 1.0f) < DBL_EPSILON) {
        return @"标准";
    }
    if (fabs(resolvedScale - 1.1f) < DBL_EPSILON) {
        return @"大";
    }
    return @"特大";
}

- (NSArray<NSNumber *> *)supportedScales {
    return self.cachedSupportedScales;
}

@end
