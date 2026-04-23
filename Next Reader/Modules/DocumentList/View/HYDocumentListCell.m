//
//  HYDocumentListCell.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYDocumentListCell.h"

#import "HYBaseLabel.h"
#import "HYDocumentItem.h"
#import "HYFileManagerService.h"

@interface HYDocumentListCell ()

@property (nonatomic, strong) UIView *iconContainerView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) HYBaseLabel *iconTextLabel;
@property (nonatomic, strong) HYBaseLabel *titleLabel;
@property (nonatomic, strong) HYBaseLabel *metaLabel;
@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation HYDocumentListCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self hy_setupSubviews];
    }
    return self;
}

- (void)hy_setupSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = HY_COLOR_BG_WHITE;

    self.iconContainerView = [[UIView alloc] init];
    self.iconContainerView.layer.cornerRadius = HY_CORNER_RADIUS_MD;
    self.iconContainerView.clipsToBounds = YES;
    [self.contentView addSubview:self.iconContainerView];

    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.iconContainerView addSubview:self.iconImageView];

    self.iconTextLabel = [[HYBaseLabel alloc] init];
    self.iconTextLabel.hy_baseFont = HY_FONT_BOLD(11.0f);
    self.iconTextLabel.textAlignment = NSTextAlignmentCenter;
    self.iconTextLabel.textColor = HY_COLOR_BG_WHITE;
    [self.iconContainerView addSubview:self.iconTextLabel];

    self.titleLabel = [[HYBaseLabel alloc] init];
    self.titleLabel.hy_baseFont = HY_FONT_MEDIUM(HY_FONT_SIZE_BODY);
    self.titleLabel.textColor = HY_COLOR_TEXT_PRIMARY;
    self.titleLabel.numberOfLines = 1;
    [self.contentView addSubview:self.titleLabel];

    self.metaLabel = [[HYBaseLabel alloc] init];
    self.metaLabel.hy_baseFont = HY_FONT_CAPTION;
    self.metaLabel.textColor = HY_COLOR_TEXT_SECONDARY;
    self.metaLabel.numberOfLines = 1;
    [self.contentView addSubview:self.metaLabel];

    self.separatorLine = [[UIView alloc] init];
    self.separatorLine.backgroundColor = HY_COLOR_SEPARATOR;
    [self.contentView addSubview:self.separatorLine];

    [self.iconContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(HY_MARGIN_MD);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(44.0f);
    }];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.iconContainerView).insets(UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f));
    }];

    [self.iconTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.iconContainerView).insets(UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f));
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(14.0f);
        make.left.equalTo(self.iconContainerView.mas_right).offset(HY_MARGIN_MD);
        make.right.equalTo(self.contentView).offset(-40.0f);
    }];

    [self.metaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(6.0f);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
    }];

    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(0.5f);
    }];
}

- (void)configWithItem:(HYDocumentItem *)item {
    self.titleLabel.text = item.fileName;
    self.metaLabel.text = [self hy_metaTextForItem:item];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    UIColor *tintColor = [self hy_colorForType:item.documentType];
    self.iconContainerView.backgroundColor = tintColor;

    UIImage *iconImage = nil;
    if (@available(iOS 13.0, *)) {
        iconImage = [UIImage systemImageNamed:item.typeSystemImageName];
    }

    self.iconImageView.image = iconImage;
    self.iconImageView.tintColor = HY_COLOR_BG_WHITE;
    self.iconImageView.hidden = iconImage == nil;
    self.iconTextLabel.hidden = iconImage != nil;
    self.iconTextLabel.text = item.typeBadgeText;
}

- (NSString *)hy_metaTextForItem:(HYDocumentItem *)item {
    NSString *sizeText = [[HYFileManagerService sharedInstance] formattedFileSize:item.fileSize];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *modifiedText = [formatter stringFromDate:item.modifiedDate];
    return [NSString stringWithFormat:@"%@  ·  %@  ·  %@", item.typeDisplayName, sizeText, modifiedText];
}

- (UIColor *)hy_colorForType:(HYDocumentType)documentType {
    switch (documentType) {
        case HYDocumentTypePDF:
            return [UIColor hy_colorWithHex:0xE34D59];
        case HYDocumentTypeWord:
            return [UIColor hy_colorWithHex:0x0052D9];
        case HYDocumentTypeExcel:
            return [UIColor hy_colorWithHex:0x00A870];
        case HYDocumentTypePPT:
            return [UIColor hy_colorWithHex:0xED7B2F];
        case HYDocumentTypeText:
            return [UIColor hy_colorWithHex:0x5E5CE6];
        case HYDocumentTypeMarkdown:
            return [UIColor hy_colorWithHex:0x24292E];
        case HYDocumentTypeUnknown:
        default:
            return HY_COLOR_TEXT_TERTIARY;
    }
}

@end
