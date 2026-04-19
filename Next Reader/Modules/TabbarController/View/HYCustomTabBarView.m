//
//  HYCustomTabBarView.m
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import "HYCustomTabBarView.h"

@implementation HYCustomTabBarView {
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

    _backgroundView.frame = self.bounds;
    _backgroundView.safeBottomInset = self.safeBottomInset;
    [_backgroundView setNeedsLayout];

    CGFloat availableWidth = CGRectGetWidth(self.bounds) - HYCustomTabBarHorizontalInset * 2.0f;
    CGFloat itemWidth = _itemViews.count > 0 ? availableWidth / (CGFloat)_itemViews.count : 0.0f;
    CGFloat itemHeight = HYCustomTabBarBodyTop + HYCustomTabBarBodyHeight + self.safeBottomInset;

    [_itemViews enumerateObjectsUsingBlock:^(HYCustomTabBarItemView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        itemView.frame = CGRectMake(HYCustomTabBarHorizontalInset + itemWidth * idx, 0.0f, itemWidth, itemHeight);
    }];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    _selectedIndex = selectedIndex;
    [_backgroundView setSelectedIndex:selectedIndex animated:animated];
    [_itemViews enumerateObjectsUsingBlock:^(HYCustomTabBarItemView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemView setItemSelected:(idx == selectedIndex) animated:animated];
    }];
}

- (void)hy_itemTapped:(HYCustomTabBarItemView *)sender {
    if (self.selectionHandler) {
        self.selectionHandler(sender.tag);
    }
}

@end
