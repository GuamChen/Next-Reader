//
//  HYCustomTabBarBackgroundView.m
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import "HYCustomTabBarBackgroundView.h"

@implementation HYCustomTabBarBackgroundView {
    // 背景只是一条 shape path，不参与交互；交互由外层 item 负责。
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
        _shapeLayer.shadowOpacity = 0.7f;
        _shapeLayer.shadowRadius = 14.0f;
        _shapeLayer.shadowOffset = CGSizeMake(0.0f, 4.0f);
        [self.layer addSublayer:_shapeLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _shapeLayer.frame = self.bounds;
    // 每次尺寸变化都重算 path，保证 safe area 或横竖屏变化后轮廓仍然正确。
    _shapeLayer.path = [self hy_backgroundPathForSelectedIndex:self.selectedIndex].CGPath;
}

- (CGFloat)itemCenterXAtIndex:(NSInteger)index {
    // 背景凸起位置的唯一依据是 item 的中心点，而不是按钮本身的 frame。
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
    pathAnimation.duration = 0.21f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // 背景凸起的“滑动感”来自 path 插值，而不是移动整个 view。
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

    NSLog(@"\n====== TabBar Path Debug ======");
    NSLog(@"selectedIndex: %ld", (long)selectedIndex);
    NSLog(@"left: %.2f right: %.2f", left, right);
    NSLog(@"selectedCenterX: %.2f", selectedCenterX);

    // ====== 关键：剩余空间计算 ======
    CGFloat edgeSafeInset = radius + 14.0f;

    CGFloat leftAvailableWidth = selectedCenterX - left - edgeSafeInset;
    CGFloat rightAvailableWidth = right - selectedCenterX - edgeSafeInset;

    NSLog(@"leftAvailableWidth: %.2f", leftAvailableWidth);
    NSLog(@"rightAvailableWidth: %.2f", rightAvailableWidth);

    CGFloat bumpHalfWidth = MIN(42.0f, MIN(MAX(42.0f, leftAvailableWidth),
                                           MAX(42.0f, rightAvailableWidth)));

    NSLog(@"最终 bumpHalfWidth: %.2f", bumpHalfWidth);

    CGFloat bumpPeakY = bodyTop - 24.0f;
    CGFloat bumpControlOffset = bumpHalfWidth * 0.58f;

    CGFloat bumpStartX = selectedCenterX - bumpHalfWidth;
    CGFloat bumpEndX = selectedCenterX + bumpHalfWidth;

    NSLog(@"bumpStartX: %.2f", bumpStartX);
    NSLog(@"bumpEndX: %.2f", bumpEndX);

    // ====== 开始画 ======
    UIBezierPath *path = [UIBezierPath bezierPath];

    CGPoint p0 = CGPointMake(left + radius, bodyTop);
    [path moveToPoint:p0];
    NSLog(@"%@", HYPoint(@"moveTo", p0));

    CGPoint p1 = CGPointMake(MAX(left + radius, bumpStartX), bodyTop);
    [path addLineToPoint:p1];
    NSLog(@"%@", HYPoint(@"lineTo(凸起起点)", p1));

    // ===== 左半弧 =====
    CGPoint c1 = CGPointMake(selectedCenterX - bumpControlOffset, bodyTop);
    CGPoint c2 = CGPointMake(selectedCenterX - bumpControlOffset, bumpPeakY);
    CGPoint p2 = CGPointMake(selectedCenterX, bumpPeakY);

    [path addCurveToPoint:p2 controlPoint1:c1 controlPoint2:c2];

    NSLog(@"%@", HYPoint(@"curveTo(山顶)", p2));
    NSLog(@"%@", HYPoint(@"control1", c1));
    NSLog(@"%@", HYPoint(@"control2", c2));

    // ===== 右半弧 =====
    CGPoint c3 = CGPointMake(selectedCenterX + bumpControlOffset, bumpPeakY);
    CGPoint c4 = CGPointMake(selectedCenterX + bumpControlOffset, bodyTop);
    CGPoint p3 = CGPointMake(MIN(right - radius, bumpEndX), bodyTop);

    [path addCurveToPoint:p3 controlPoint1:c3 controlPoint2:c4];

    NSLog(@"%@", HYPoint(@"curveTo(回落)", p3));
    NSLog(@"%@", HYPoint(@"control3", c3));
    NSLog(@"%@", HYPoint(@"control4", c4));

    CGPoint p4 = CGPointMake(right - radius, bodyTop);
    [path addLineToPoint:p4];
    NSLog(@"%@", HYPoint(@"lineTo(右上角前)", p4));

    // ===== 右上角圆角 =====
    CGPoint p5 = CGPointMake(right, bodyTop + radius);
    [path addQuadCurveToPoint:p5 controlPoint:CGPointMake(right, bodyTop)];
    NSLog(@"%@", HYPoint(@"quadTo(右上角)", p5));

    CGPoint p6 = CGPointMake(right, bottom - radius);
    [path addLineToPoint:p6];
    NSLog(@"%@", HYPoint(@"lineTo(右下角前)", p6));

    CGPoint p7 = CGPointMake(right - radius, bottom);
    [path addQuadCurveToPoint:p7 controlPoint:CGPointMake(right, bottom)];
    NSLog(@"%@", HYPoint(@"quadTo(右下角)", p7));

    CGPoint p8 = CGPointMake(left + radius, bottom);
    [path addLineToPoint:p8];
    NSLog(@"%@", HYPoint(@"lineTo(左下角前)", p8));

    CGPoint p9 = CGPointMake(left, bottom - radius);
    [path addQuadCurveToPoint:p9 controlPoint:CGPointMake(left, bottom)];
    NSLog(@"%@", HYPoint(@"quadTo(左下角)", p9));

    CGPoint p10 = CGPointMake(left, bodyTop + radius);
    [path addLineToPoint:p10];
    NSLog(@"%@", HYPoint(@"lineTo(左上角前)", p10));

    CGPoint p11 = CGPointMake(left + radius, bodyTop);
    [path addQuadCurveToPoint:p11 controlPoint:CGPointMake(left, bodyTop)];
    NSLog(@"%@", HYPoint(@"quadTo(左上角)", p11));

    [path closePath];
    NSLog(@"closePath");

    return path;
}

static inline NSString *HYPoint(NSString *name, CGPoint p) {
    return [NSString stringWithFormat:@"%@:(%.2f, %.2f)", name, p.x, p.y];
}
@end
