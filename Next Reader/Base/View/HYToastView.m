//
//  HYToastView.m
//  Next Reader
//
//  Created by Gavin on 2026/4/17.
//

#import "HYToastView.h"

@implementation HYToastView

+ (void)showInView:(UIView *)view text:(NSString *)text duration:(NSTimeInterval)duration {
    if (!view || HY_STRING_IS_EMPTY(text)) {
        return;
    }

    for (UIView *subview in view.subviews.reverseObjectEnumerator) {
        if ([subview isKindOfClass:[HYToastView class]]) {
            [subview removeFromSuperview];
        }
    }

    HYToastView *toastView = [[HYToastView alloc] init];
    toastView.alpha = 0.0f;
    toastView.backgroundColor = [UIColor hy_colorWithHex:0x000000 alpha:0.80f];
    toastView.layer.cornerRadius = HY_CORNER_RADIUS_MD;
    toastView.clipsToBounds = YES;

    toastView.textLabel = [[UILabel alloc] init];
    toastView.textLabel.text = text;
    toastView.textLabel.textColor = HY_COLOR_BG_WHITE;
    toastView.textLabel.font = HY_FONT_CAPTION;
    toastView.textLabel.textAlignment = NSTextAlignmentCenter;
    toastView.textLabel.numberOfLines = 0;
    [toastView addSubview:toastView.textLabel];

    [view addSubview:toastView];

    [toastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.bottom.equalTo(view.mas_safeAreaLayoutGuideBottom).offset(-HY_MARGIN_XXL);
        make.left.greaterThanOrEqualTo(view).offset(HY_MARGIN_XL);
        make.right.lessThanOrEqualTo(view).offset(-HY_MARGIN_XL);
    }];

    [toastView.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(toastView).insets(UIEdgeInsetsMake(HY_MARGIN_SM, HY_MARGIN_MD, HY_MARGIN_SM, HY_MARGIN_MD));
    }];

    [UIView animateWithDuration:HY_ANIMATION_DURATION_NORMAL animations:^{
        toastView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX(duration, 1.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:HY_ANIMATION_DURATION_NORMAL animations:^{
                toastView.alpha = 0.0f;
            } completion:^(BOOL finishedInner) {
                [toastView removeFromSuperview];
            }];
        });
    }];
}

@end
