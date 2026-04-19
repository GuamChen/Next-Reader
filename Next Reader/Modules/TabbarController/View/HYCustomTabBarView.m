//
//  HYCustomTabBarView.m
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import "HYCustomTabBarView.h"

#import "HYCustomTabBarBackgroundView.h"
#import "HYCustomTabBarItemView.h"

@implementation HYCustomTabBarView {
    // 背景和 item 分层管理：背景只画形状，item 只做图标/文字/动画。
    HYCustomTabBarBackgroundView *_backgroundView;
    NSMutableArray<HYCustomTabBarItemView *> *_itemViews;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _itemViews = [NSMutableArray array];
        _backgroundView = [[HYCustomTabBarBackgroundView alloc] init];
        [self addSubview:_backgroundView];
    }
    return self;
}

- (void)configureWithItems:(NSArray<NSDictionary<NSString *, id> *> *)items {
    // 重新配置时先清空旧 item，保证这个 view 可以重复复用。
    for (HYCustomTabBarItemView *itemView in _itemViews) {
        [itemView removeFromSuperview];
    }
    [_itemViews removeAllObjects];

    _backgroundView.itemCount = items.count;
    [self addSubview:_backgroundView];

    [items enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        HYCustomTabBarItemView *itemView = [[HYCustomTabBarItemView alloc] initWithTitle:item[@"title"]
                                                                              normalImage:item[@"normalImage"]
                                                                            selectedImage:item[@"selectedImage"]];
        itemView.tag = idx;
        [itemView addTarget:self action:@selector(hy_itemTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:itemView];
        [_itemViews addObject:itemView];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // 背景铺满整个自定义 tabbar，内部 path 再根据 selectedIndex 决定凸起位置。
    _backgroundView.frame = self.bounds;
    _backgroundView.safeBottomInset = self.safeBottomInset;
    [_backgroundView setNeedsLayout];

    // item 本身仍然是标准等宽布局，只是选中态视觉会上浮。
    CGFloat availableWidth = CGRectGetWidth(self.bounds) - HYCustomTabBarHorizontalInset * 2.0f;
    CGFloat itemWidth = _itemViews.count > 0 ? availableWidth / (CGFloat)_itemViews.count : 0.0f;
    CGFloat itemHeight = HYCustomTabBarBodyTop + HYCustomTabBarBodyHeight + self.safeBottomInset;

    [_itemViews enumerateObjectsUsingBlock:^(HYCustomTabBarItemView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        itemView.frame = CGRectMake(HYCustomTabBarHorizontalInset + itemWidth * idx, 0.0f, itemWidth, itemHeight);
    }];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    _selectedIndex = selectedIndex;
    // 同一个 selectedIndex 同时驱动背景凸起和每个 item 的视觉状态。
    [_backgroundView setSelectedIndex:selectedIndex animated:animated];
    [_itemViews enumerateObjectsUsingBlock:^(HYCustomTabBarItemView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemView setItemSelected:(idx == selectedIndex) animated:animated];
    }];
}

- (void)hy_itemTapped:(HYCustomTabBarItemView *)sender {
    if (self.selectionHandler) {
        // HYCustomTabBarView 不直接切页，只把点击意图回传给 controller。
        self.selectionHandler(sender.tag);
    }
}

@end
