#import "HYFontSettingViewController.h"

#import "HYBaseButton.h"
#import "HYFontManager.h"

@interface HYFontSettingViewController ()

@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) NSArray<HYBaseButton *> *scaleButtons;
@property (nonatomic, strong) UILabel *previewTitleLabel;
@property (nonatomic, strong) UILabel *previewBodyLabel;
@property (nonatomic, strong) UIButton *previewActionButton;
@property (nonatomic, assign) CGFloat pendingScale;

@end

@implementation HYFontSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hy_setNavTitle:@"字体大小"];
    [self hy_setRightButtonWithTitle:@"保存" image:nil target:self action:@selector(hy_saveFontScale)];
    self.pendingScale = [HYFontManager sharedManager].currentScale;
    [self hy_setupSubviews];
    [self hy_applyPreviewScale:self.pendingScale];
}

- (void)hy_setupSubviews {
    self.view.backgroundColor = [UIColor hy_colorWithHex:0xF5F7FA];

    self.panelView = [HYUIBuildFactory viewWithBackgroundColor:HY_COLOR_BG_WHITE];
    self.panelView.layer.cornerRadius = HY_CORNER_RADIUS_LG;
    [self.hy_contentView addSubview:self.panelView];

    UILabel *titleLabel = [HYUIBuildFactory labelWithFont:HY_FONT_MEDIUM(17.0f)
                                                textColor:HY_COLOR_TEXT_PRIMARY
                                                alignment:NSTextAlignmentLeft];
    titleLabel.text = @"实时预览";
    [self.panelView addSubview:titleLabel];

    self.previewTitleLabel = [HYUIBuildFactory labelWithFont:HY_FONT_MEDIUM(20.0f)
                                                   textColor:HY_COLOR_TEXT_PRIMARY
                                                   alignment:NSTextAlignmentLeft];
    self.previewTitleLabel.text = @"全局字体大小调节";
    [self.panelView addSubview:self.previewTitleLabel];

    self.previewBodyLabel = [HYUIBuildFactory labelWithFont:HY_FONT(HY_FONT_SIZE_BODY)
                                                  textColor:HY_COLOR_TEXT_SECONDARY
                                                  alignment:NSTextAlignmentLeft];
    self.previewBodyLabel.numberOfLines = 0;
    self.previewBodyLabel.text = @"拖动滑块或点击下方档位按钮，当前页面会实时预览变化。点击右上角“保存”后，全局列表和 TabBar 标题立即生效。";
    [self.panelView addSubview:self.previewBodyLabel];

    self.previewActionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.previewActionButton.layer.cornerRadius = HY_CORNER_RADIUS_MD;
    self.previewActionButton.backgroundColor = HY_COLOR_THEME;
    [self.previewActionButton setTitle:@"预览按钮" forState:UIControlStateNormal];
    [self.previewActionButton setTitleColor:HY_COLOR_BG_WHITE forState:UIControlStateNormal];
    [self.panelView addSubview:self.previewActionButton];

    self.slider = [[UISlider alloc] init];
    self.slider.minimumValue = 0.0f;
    self.slider.maximumValue = 3.0f;
    self.slider.continuous = YES;
    [self.slider addTarget:self action:@selector(hy_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(hy_sliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.hy_contentView addSubview:self.slider];

    NSMutableArray<HYBaseButton *> *buttons = [NSMutableArray array];
    NSArray<NSNumber *> *scales = [[HYFontManager sharedManager] supportedScales];
    for (NSUInteger index = 0; index < scales.count; index++) {
        HYBaseButton *button = [HYBaseButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        button.hy_baseFont = HY_FONT_MEDIUM(15.0f);
        button.layer.cornerRadius = HY_CORNER_RADIUS_MD;
        button.layer.borderWidth = 1.0f;
        [button setTitle:[[HYFontManager sharedManager] displayTitleForScale:scales[index].floatValue] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(hy_scaleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.hy_contentView addSubview:button];
        [buttons addObject:button];
    }
    self.scaleButtons = buttons.copy;

    [self.panelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hy_contentView).offset(HY_MARGIN_MD);
        make.left.equalTo(self.hy_contentView).offset(HY_MARGIN_MD);
        make.right.equalTo(self.hy_contentView).offset(-HY_MARGIN_MD);
    }];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.panelView).offset(HY_MARGIN_LG);
        make.left.equalTo(self.panelView).offset(HY_MARGIN_LG);
        make.right.equalTo(self.panelView).offset(-HY_MARGIN_LG);
    }];

    [self.previewTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(HY_MARGIN_MD);
        make.left.right.equalTo(titleLabel);
    }];

    [self.previewBodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.previewTitleLabel.mas_bottom).offset(HY_MARGIN_SM);
        make.left.right.equalTo(titleLabel);
    }];

    [self.previewActionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.previewBodyLabel.mas_bottom).offset(HY_MARGIN_LG);
        make.left.equalTo(titleLabel);
        make.width.mas_equalTo(120.0f);
        make.height.mas_equalTo(40.0f);
        make.bottom.equalTo(self.panelView).offset(-HY_MARGIN_LG);
    }];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.panelView.mas_bottom).offset(HY_MARGIN_XL);
        make.left.equalTo(self.hy_contentView).offset(HY_MARGIN_XL);
        make.right.equalTo(self.hy_contentView).offset(-HY_MARGIN_XL);
    }];

    [self.scaleButtons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:12.0f leadSpacing:HY_MARGIN_MD tailSpacing:HY_MARGIN_MD];
    [self.scaleButtons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.slider.mas_bottom).offset(HY_MARGIN_LG);
        make.height.mas_equalTo(44.0f);
    }];
}

- (void)hy_sliderValueChanged:(UISlider *)slider {
    NSInteger index = (NSInteger)lroundf(slider.value);
    NSArray<NSNumber *> *scales = [[HYFontManager sharedManager] supportedScales];
    self.pendingScale = scales[index].floatValue;
    [self hy_applyPreviewScale:self.pendingScale];
}

- (void)hy_sliderTouchEnded:(UISlider *)slider {
    NSInteger index = (NSInteger)lroundf(slider.value);
    slider.value = (float)index;
}

- (void)hy_scaleButtonTapped:(HYBaseButton *)sender {
    NSArray<NSNumber *> *scales = [[HYFontManager sharedManager] supportedScales];
    if (sender.tag >= scales.count) {
        return;
    }
    self.pendingScale = scales[sender.tag].floatValue;
    self.slider.value = (float)sender.tag;
    [self hy_applyPreviewScale:self.pendingScale];
}

- (void)hy_applyPreviewScale:(CGFloat)scale {
    NSArray<NSNumber *> *scales = [[HYFontManager sharedManager] supportedScales];
    NSUInteger selectedIndex = [scales indexOfObjectPassingTest:^BOOL(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return fabs(obj.floatValue - scale) < 0.0001f;
    }];
    if (selectedIndex == NSNotFound) {
        selectedIndex = 1;
    }
    self.slider.value = (float)selectedIndex;

    UIFont *titleBaseFont = HY_FONT_MEDIUM(20.0f);
    UIFont *bodyBaseFont = HY_FONT(HY_FONT_SIZE_BODY);
    UIFont *buttonBaseFont = HY_FONT_MEDIUM(15.0f);
    self.previewTitleLabel.font = [UIFont fontWithDescriptor:titleBaseFont.fontDescriptor size:titleBaseFont.pointSize * scale];
    self.previewBodyLabel.font = [UIFont fontWithDescriptor:bodyBaseFont.fontDescriptor size:bodyBaseFont.pointSize * scale];
    self.previewActionButton.titleLabel.font = [UIFont fontWithDescriptor:buttonBaseFont.fontDescriptor size:buttonBaseFont.pointSize * scale];

    [self.scaleButtons enumerateObjectsUsingBlock:^(HYBaseButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isSelected = idx == selectedIndex;
        UIColor *titleColor = isSelected ? HY_COLOR_BG_WHITE : HY_COLOR_TEXT_PRIMARY;
        UIColor *backgroundColor = isSelected ? HY_COLOR_THEME : HY_COLOR_BG_WHITE;
        UIColor *borderColor = isSelected ? HY_COLOR_THEME : HY_COLOR_SEPARATOR_DARK;
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        button.backgroundColor = backgroundColor;
        button.layer.borderColor = borderColor.CGColor;
    }];
}

- (void)hy_saveFontScale {
    [[HYFontManager sharedManager] saveFontScale:self.pendingScale];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
