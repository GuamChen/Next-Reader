#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const HYFontSizeDidChangeNotification;

@interface HYFontManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, assign, readonly) CGFloat currentScale;

- (void)saveFontScale:(CGFloat)fontScale;
- (CGFloat)closestSupportedScaleForScale:(CGFloat)fontScale;
- (UIFont *)scaledFontFromBaseFont:(UIFont *)baseFont;
- (NSString *)displayTitleForScale:(CGFloat)fontScale;
- (NSArray<NSNumber *> *)supportedScales;

@end

NS_ASSUME_NONNULL_END
