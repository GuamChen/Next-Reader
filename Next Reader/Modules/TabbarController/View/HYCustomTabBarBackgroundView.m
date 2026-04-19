//
//  HYCustomTabBarBackgroundView.m
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import "HYCustomTabBarBackgroundView.h"

@implementation HYCustomTabBarBackgroundView {
    CAShapeLayer *_shapeLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _itemCount = 3;
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor hy_colorWithHex:0xFBFBFC].CGColor;
        _shapeLayer.strokeColor = [UIColor colorWithWhite:0.82f alpha:0.9f].CGColor;
        _shapeLayer.lineWidth = 1.0f;
        _shapeLayer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.10f].CGColor;
        _shapeLayer.shadowOpacity = 1.0f;
        _shapeLayer.shadowRadius = 18.0f;
        _shapeLayer.shadowOffset = CGSizeMake(0.0f, 6.0f);
        [self.layer addSublayer:_shapeLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _shapeLayer.frame = self.bounds;
    _shapeLayer.path = [self hy_backgroundPathForSelectedIndex:self.selectedIndex].CGPath;
}

- (CGFloat)itemCenterXAtIndex:(NSInteger)index {
    CGFloat availableWidth = CGRectGetWidth(self.bounds) - HYCustomTabBarHorizontalInset * 2.0f;
    if (self.itemCount <= 0 || availableWidth <= 0.0f) {
        return CGRectGetMidX(self.bounds);
    }
    CGFloat itemWidth = availableWidth / (CGFloat)self.itemCount;
    return HYCustomTabBarHorizontalInset + itemWidth * ((CGFloat)index + 0.5f);
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    UIBezierPath *fromPath = [UIBezierPath bezierPathWithCGPath:_shapeLayer.path ?: [self hy_backgroundPathForSelectedIndex:self.selectedIndex].CGPath];
    _selectedIndex = selectedIndex;
    UIBezierPath *toPath = [self hy_backgroundPathForSelectedIndex:selectedIndex];
    _shapeLayer.path = toPath.CGPath;

    if (!animated) {
        return;
    }

    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id)fromPath.CGPath;
    pathAnimation.toValue = (__bridge id)toPath.CGPath;
    pathAnimation.duration = HY_ANIMATION_DURATION_SLOW;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_shapeLayer addAnimation:pathAnimation forKey:@"hy_path"];
}

- (UIBezierPath *)hy_backgroundPathForSelectedIndex:(NSInteger)selectedIndex {
    CGFloat bodyTop = HYCustomTabBarBodyTop;
    CGFloat bodyHeight = HYCustomTabBarBodyHeight + self.safeBottomInset;
    CGFloat left = HYCustomTabBarHorizontalInset;
    CGFloat right = CGRectGetWidth(self.bounds) - HYCustomTabBarHorizontalInset;
    CGFloat bottom = bodyTop + bodyHeight;
    CGFloat radius = HYCustomTabBarCornerRadius;
    CGFloat selectedCenterX = [self itemCenterXAtIndex:MAX(0, MIN(self.itemCount - 1, selectedIndex))];

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(left + radius, bodyTop)];

    CGFloat bumpStartX = selectedCenterX - 54.0f;
    CGFloat bumpEndX = selectedCenterX + 54.0f;
    [path addLineToPoint:CGPointMake(MAX(left + radius, bumpStartX), bodyTop)];
    [path addCurveToPoint:CGPointMake(selectedCenterX - 30.0f, bodyTop - 8.0f)
            controlPoint1:CGPointMake(selectedCenterX - 42.0f, bodyTop)
            controlPoint2:CGPointMake(selectedCenterX - 38.0f, bodyTop - 8.0f)];
    [path addCurveToPoint:CGPointMake(selectedCenterX, bodyTop - 28.0f)
            controlPoint1:CGPointMake(selectedCenterX - 20.0f, bodyTop - 8.0f)
            controlPoint2:CGPointMake(selectedCenterX - 18.0f, bodyTop - 28.0f)];
    [path addCurveToPoint:CGPointMake(selectedCenterX + 30.0f, bodyTop - 8.0f)
            controlPoint1:CGPointMake(selectedCenterX + 18.0f, bodyTop - 28.0f)
            controlPoint2:CGPointMake(selectedCenterX + 20.0f, bodyTop - 8.0f)];
    [path addCurveToPoint:CGPointMake(MIN(right - radius, bumpEndX), bodyTop)
            controlPoint1:CGPointMake(selectedCenterX + 38.0f, bodyTop - 8.0f)
            controlPoint2:CGPointMake(selectedCenterX + 42.0f, bodyTop)];

    [path addLineToPoint:CGPointMake(right - radius, bodyTop)];
    [path addQuadCurveToPoint:CGPointMake(right, bodyTop + radius) controlPoint:CGPointMake(right, bodyTop)];
    [path addLineToPoint:CGPointMake(right, bottom - radius)];
    [path addQuadCurveToPoint:CGPointMake(right - radius, bottom) controlPoint:CGPointMake(right, bottom)];
    [path addLineToPoint:CGPointMake(left + radius, bottom)];
    [path addQuadCurveToPoint:CGPointMake(left, bottom - radius) controlPoint:CGPointMake(left, bottom)];
    [path addLineToPoint:CGPointMake(left, bodyTop + radius)];
    [path addQuadCurveToPoint:CGPointMake(left + radius, bodyTop) controlPoint:CGPointMake(left, bodyTop)];
    [path closePath];
    return path;
}

@end
