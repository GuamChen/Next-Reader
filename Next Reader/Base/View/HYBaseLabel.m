#import "HYBaseLabel.h"

#import "HYFontManager.h"

@interface HYBaseLabel ()

@property (nonatomic, assign) BOOL hy_applyingScaledFont;

@end

@implementation HYBaseLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hy_commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hy_fontSizeDidChangeNotification:)
                                                 name:HYFontSizeDidChangeNotification
                                               object:nil];
}

- (void)setFont:(UIFont *)font {
    if (self.hy_applyingScaledFont) {
        [super setFont:font];
        return;
    }

    self.hy_baseFont = font;
    [self applyFontSize];
}

- (void)setHy_baseFont:(UIFont *)hy_baseFont {
    _hy_baseFont = hy_baseFont;
    [self applyFontSize];
}

- (void)applyFontSize {
    UIFont *baseFont = self.hy_baseFont ?: [UIFont systemFontOfSize:17.0f];
    UIFont *scaledFont = [[HYFontManager sharedManager] scaledFontFromBaseFont:baseFont];
    self.hy_applyingScaledFont = YES;
    [UIView transitionWithView:self
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
        [super setFont:scaledFont];
    } completion:nil];
    self.hy_applyingScaledFont = NO;
}

- (void)hy_fontSizeDidChangeNotification:(NSNotification *)notification {
    [self applyFontSize];
}

@end
