//
//  HYCustomTabBarView.h
//  Next Reader
//
//  Created by Gavin on 2026/4/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYCustomTabBarView : UIView

@property (nonatomic, copy) void (^selectionHandler)(NSInteger index);
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGFloat safeBottomInset;

- (void)configureWithItems:(NSArray<NSDictionary<NSString *, id> *> *)items;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
