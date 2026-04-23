#import "HYBaseButton.h"

#import "HYFontManager.h"

@implementation HYBaseButton

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

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.hy_baseFont == nil && self.titleLabel.font != nil) {
        self.hy_baseFont = self.titleLabel.font;
    }
}

- (void)setHy_baseFont:(UIFont *)hy_baseFont {
    _hy_baseFont = hy_baseFont;
    [self applyFontSize];
}

- (void)applyFontSize {
    UIFont *baseFont = self.hy_baseFont ?: self.titleLabel.font ?: [UIFont systemFontOfSize:16.0f];
    UIFont *scaledFont = [[HYFontManager sharedManager] scaledFontFromBaseFont:baseFont];
    [UIView transitionWithView:self.titleLabel
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
        self.titleLabel.font = scaledFont;
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)hy_fontSizeDidChangeNotification:(NSNotification *)notification {
    [self applyFontSize];
}

@end
