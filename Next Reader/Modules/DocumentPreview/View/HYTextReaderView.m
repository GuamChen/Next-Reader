//
//  HYTextReaderView.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYTextReaderView.h"

static CGFloat const HYTextReaderMinimumFontSize = 13.0f;
static CGFloat const HYTextReaderMaximumFontSize = 24.0f;
static CGFloat const HYTextReaderDefaultFontSize = 15.0f;

@interface HYTextReaderView () <UISearchBarDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISegmentedControl *themeControl;
@property (nonatomic, strong) UIButton *decreaseFontButton;
@property (nonatomic, strong) UIButton *increaseFontButton;
@property (nonatomic, strong) UILabel *matchLabel;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, copy) NSString *rawText;
@property (nonatomic, copy) NSString *cacheKey;
@property (nonatomic, assign) CGFloat fontSize;

@end

@implementation HYTextReaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self hy_setupSubviews];
        self.fontSize = HYTextReaderDefaultFontSize;
        [self hy_applyThemeAtIndex:0];
    }
    return self;
}

- (void)dealloc {
    [self hy_saveReadingPosition];
}

- (void)hy_setupSubviews {
    self.backgroundColor = HY_COLOR_BG_WHITE;

    self.toolbarView = [HYUIBuildFactory viewWithBackgroundColor:HY_COLOR_BG_LIGHT_GRAY];
    [self addSubview:self.toolbarView];

    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"搜索正文";
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.toolbarView addSubview:self.searchBar];

    self.themeControl = [[UISegmentedControl alloc] initWithItems:@[@"浅色", @"护眼", @"夜间"]];
    self.themeControl.selectedSegmentIndex = 0;
    [self.themeControl addTarget:self action:@selector(hy_themeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.toolbarView addSubview:self.themeControl];

    self.decreaseFontButton = [self hy_fontButtonWithTitle:@"A-"];
    [self.decreaseFontButton addTarget:self action:@selector(hy_decreaseFontSize) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView addSubview:self.decreaseFontButton];

    self.increaseFontButton = [self hy_fontButtonWithTitle:@"A+"];
    [self.increaseFontButton addTarget:self action:@selector(hy_increaseFontSize) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView addSubview:self.increaseFontButton];

    self.matchLabel = [[UILabel alloc] init];
    self.matchLabel.textColor = HY_COLOR_TEXT_SECONDARY;
    self.matchLabel.font = HY_FONT_SMALL;
    self.matchLabel.textAlignment = NSTextAlignmentRight;
    self.matchLabel.text = @"未搜索";
    [self.toolbarView addSubview:self.matchLabel];

    self.textView = [[UITextView alloc] init];
    self.textView.editable = NO;
    self.textView.selectable = YES;
    self.textView.alwaysBounceVertical = YES;
    self.textView.scrollsToTop = YES;
    self.textView.textContainerInset = UIEdgeInsetsMake(HY_MARGIN_XL, HY_MARGIN_LG, HY_MARGIN_XXL, HY_MARGIN_LG);
    self.textView.font = [UIFont fontWithName:@"Menlo-Regular" size:HYTextReaderDefaultFontSize] ?: [UIFont systemFontOfSize:HYTextReaderDefaultFontSize];
    self.textView.scrollEnabled = YES;
    self.textView.panGestureRecognizer.cancelsTouchesInView = NO;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    self.textView.showsVerticalScrollIndicator = YES;
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, HY_MARGIN_XXL, 0);
    [self addSubview:self.textView];
    ((UIScrollView *)self.textView).delegate = self;

    [self.toolbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
    }];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolbarView).offset(HY_MARGIN_XS);
        make.left.equalTo(self.toolbarView).offset(HY_MARGIN_SM);
        make.right.equalTo(self.toolbarView).offset(-HY_MARGIN_SM);
    }];

    [self.themeControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(HY_MARGIN_XS);
        make.left.equalTo(self.toolbarView).offset(HY_MARGIN_MD);
        make.width.mas_equalTo(180.0f);
        make.bottom.equalTo(self.toolbarView).offset(-HY_MARGIN_XS);
    }];

    [self.increaseFontButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.themeControl);
        make.right.equalTo(self.toolbarView).offset(-HY_MARGIN_MD);
        make.width.mas_equalTo(38.0f);
        make.height.mas_equalTo(30.0f);
    }];

    [self.decreaseFontButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.themeControl);
        make.right.equalTo(self.increaseFontButton.mas_left).offset(-HY_MARGIN_XS);
        make.width.height.equalTo(self.increaseFontButton);
    }];

    [self.matchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.themeControl);
        make.right.equalTo(self.decreaseFontButton.mas_left).offset(-HY_MARGIN_MD);
        make.left.greaterThanOrEqualTo(self.themeControl.mas_right).offset(HY_MARGIN_MD);
    }];

    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolbarView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

- (UIButton *)hy_fontButtonWithTitle:(NSString *)title {
    UIButton *button = [HYUIBuildFactory buttonWithTitle:title
                                              titleColor:HY_COLOR_TEXT_PRIMARY
                                                    font:HY_FONT_MEDIUM(14.0f)
                                                  target:nil
                                                  action:nil];
    button.layer.cornerRadius = HY_CORNER_RADIUS_SM;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = HY_COLOR_SEPARATOR.CGColor;
    return button;
}

- (void)updateWithText:(NSString *)text cacheKey:(NSString *)cacheKey {
    self.rawText = text ?: HY_STRING_EMPTY;
    self.cacheKey = cacheKey;
    self.searchBar.text = nil;
    self.matchLabel.text = @"未搜索";
    [self hy_renderTextHighlightingKeyword:nil];
    [self hy_restoreReadingPositionIfNeeded];
}

- (void)hy_themeChanged:(UISegmentedControl *)sender {
    [self hy_applyThemeAtIndex:sender.selectedSegmentIndex];
    [self hy_renderTextHighlightingKeyword:self.searchBar.text];
}

- (void)hy_applyThemeAtIndex:(NSInteger)index {
    UIColor *backgroundColor = HY_COLOR_BG_WHITE;
    UIColor *textColor = HY_COLOR_TEXT_PRIMARY;

    if (index == 1) {
        backgroundColor = [UIColor hy_colorWithHex:0xF6F2E7];
        textColor = [UIColor hy_colorWithHex:0x4A4036];
    } else if (index == 2) {
        backgroundColor = [UIColor hy_colorWithHex:0x1F1F1F];
        textColor = [UIColor hy_colorWithHex:0xE6E6E6];
    }

    self.backgroundColor = backgroundColor;
    self.textView.backgroundColor = backgroundColor;
    self.textView.textColor = textColor;
    self.toolbarView.backgroundColor = index == 2 ? [UIColor hy_colorWithHex:0x2A2A2A] : HY_COLOR_BG_LIGHT_GRAY;
    UIColor *buttonTextColor = index == 2 ? [UIColor hy_colorWithHex:0xE6E6E6] : HY_COLOR_TEXT_PRIMARY;
    UIColor *buttonBorderColor = index == 2 ? [UIColor hy_colorWithHex:0x4A4A4A] : HY_COLOR_SEPARATOR;
    [self.decreaseFontButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [self.increaseFontButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    self.decreaseFontButton.layer.borderColor = buttonBorderColor.CGColor;
    self.increaseFontButton.layer.borderColor = buttonBorderColor.CGColor;
}

- (void)hy_renderTextHighlightingKeyword:(NSString *)keyword {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6.0f;

    UIColor *foregroundColor = self.themeControl.selectedSegmentIndex == 2 ? [UIColor hy_colorWithHex:0xE6E6E6] : HY_COLOR_TEXT_PRIMARY;
    if (self.themeControl.selectedSegmentIndex == 1) {
        foregroundColor = [UIColor hy_colorWithHex:0x4A4036];
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.rawText attributes:@{
        NSFontAttributeName: [UIFont fontWithName:@"Menlo-Regular" size:self.fontSize] ?: [UIFont systemFontOfSize:self.fontSize],
        NSForegroundColorAttributeName: foregroundColor,
        NSParagraphStyleAttributeName: paragraphStyle,
    }];

    NSUInteger matchCount = 0;
    if (!HY_STRING_IS_EMPTY(keyword)) {
        NSString *lowerText = self.rawText.lowercaseString;
        NSString *lowerKeyword = keyword.lowercaseString;
        NSRange searchRange = NSMakeRange(0, lowerText.length);
        while (searchRange.location != NSNotFound && searchRange.location < lowerText.length) {
            NSRange foundRange = [lowerText rangeOfString:lowerKeyword options:0 range:searchRange];
            if (foundRange.location == NSNotFound) {
                break;
            }
            [attributedText addAttribute:NSBackgroundColorAttributeName value:[UIColor hy_colorWithHex:0xFFE58F] range:foundRange];
            [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor hy_colorWithHex:0x1A1A1A] range:foundRange];
            matchCount += 1;
            NSUInteger nextLocation = NSMaxRange(foundRange);
            if (nextLocation >= lowerText.length) {
                break;
            }
            searchRange = NSMakeRange(nextLocation, lowerText.length - nextLocation);
        }
    }

    self.textView.attributedText = attributedText;
    self.matchLabel.text = HY_STRING_IS_EMPTY(keyword) ? @"未搜索" : [NSString stringWithFormat:@"匹配 %lu 项", (unsigned long)matchCount];
}

- (void)hy_decreaseFontSize {
    self.fontSize = MAX(HYTextReaderMinimumFontSize, self.fontSize - 1.0f);
    [self hy_renderTextHighlightingKeyword:self.searchBar.text];
    [self hy_restoreReadingPositionIfNeeded];
}

- (void)hy_increaseFontSize {
    self.fontSize = MIN(HYTextReaderMaximumFontSize, self.fontSize + 1.0f);
    [self hy_renderTextHighlightingKeyword:self.searchBar.text];
    [self hy_restoreReadingPositionIfNeeded];
}

- (NSString *)hy_progressDefaultsKey {
    if (HY_STRING_IS_EMPTY(self.cacheKey)) {
        return nil;
    }
    return [NSString stringWithFormat:@"com.nextreader.text.progress.%@", self.cacheKey];
}

- (void)hy_restoreReadingPositionIfNeeded {
    NSString *defaultsKey = [self hy_progressDefaultsKey];
    if (defaultsKey == nil) {
        return;
    }

    CGFloat progress = [[NSUserDefaults standardUserDefaults] floatForKey:defaultsKey];
    if (progress <= 0.0f) {
        self.textView.contentOffset = CGPointZero;
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat maxOffsetY = MAX(self.textView.contentSize.height - self.textView.bounds.size.height, 0.0f);
        CGFloat offsetY = MIN(maxOffsetY, maxOffsetY * progress);
        [self.textView setContentOffset:CGPointMake(0.0f, offsetY) animated:NO];
    });
}

- (void)hy_saveReadingPosition {
    NSString *defaultsKey = [self hy_progressDefaultsKey];
    if (defaultsKey == nil) {
        return;
    }

    CGFloat maxOffsetY = MAX(self.textView.contentSize.height - self.textView.bounds.size.height, 1.0f);
    CGFloat progress = MIN(MAX(self.textView.contentOffset.y / maxOffsetY, 0.0f), 1.0f);
    [[NSUserDefaults standardUserDefaults] setFloat:progress forKey:defaultsKey];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self hy_renderTextHighlightingKeyword:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self hy_saveReadingPosition];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self hy_saveReadingPosition];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self hy_saveReadingPosition];
}

@end
