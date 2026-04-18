//
//  HYTextReaderView.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYTextReaderView.h"

@interface HYTextReaderView () <UISearchBarDelegate>

@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISegmentedControl *themeControl;
@property (nonatomic, strong) UILabel *matchLabel;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, copy) NSString *rawText;

@end

@implementation HYTextReaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self hy_setupSubviews];
        [self hy_applyThemeAtIndex:0];
    }
    return self;
}

- (void)hy_setupSubviews {
    self.backgroundColor = HY_COLOR_BG_WHITE;

    self.toolbarView = [[UIView alloc] init];
    self.toolbarView.backgroundColor = HY_COLOR_BG_LIGHT_GRAY;
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
    self.textView.textContainerInset = UIEdgeInsetsMake(HY_MARGIN_XL, HY_MARGIN_LG, HY_MARGIN_XXL, HY_MARGIN_LG);
    self.textView.font = [UIFont fontWithName:@"Menlo-Regular" size:15.0f] ?: HY_FONT_BODY;
    [self addSubview:self.textView];

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

    [self.matchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.themeControl);
        make.right.equalTo(self.toolbarView).offset(-HY_MARGIN_MD);
        make.left.greaterThanOrEqualTo(self.themeControl.mas_right).offset(HY_MARGIN_MD);
    }];

    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolbarView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

- (void)updateWithText:(NSString *)text {
    self.rawText = text ?: HY_STRING_EMPTY;
    self.searchBar.text = nil;
    self.matchLabel.text = @"未搜索";
    [self hy_renderTextHighlightingKeyword:nil];
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
}

- (void)hy_renderTextHighlightingKeyword:(NSString *)keyword {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6.0f;

    UIColor *foregroundColor = self.themeControl.selectedSegmentIndex == 2 ? [UIColor hy_colorWithHex:0xE6E6E6] : HY_COLOR_TEXT_PRIMARY;
    if (self.themeControl.selectedSegmentIndex == 1) {
        foregroundColor = [UIColor hy_colorWithHex:0x4A4036];
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.rawText attributes:@{
        NSFontAttributeName: self.textView.font ?: HY_FONT_BODY,
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self hy_renderTextHighlightingKeyword:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
