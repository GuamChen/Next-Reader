//
//  HYDocumentPreviewViewController.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYDocumentPreviewViewController.h"

#import "HYDocumentItem.h"
#import "HYFileManagerService.h"

@interface HYDocumentPreviewViewController ()

@property (nonatomic, strong) HYDocumentItem *documentItem;
@property (nonatomic, strong) UILabel *summaryLabel;

@end

@implementation HYDocumentPreviewViewController

- (instancetype)initWithDocumentItem:(HYDocumentItem *)documentItem {
    self = [super init];
    if (self) {
        _documentItem = documentItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hy_setNavTitle:self.documentItem.fileName];
    [self hy_setRightButtonWithTitle:nil image:nil target:nil action:nil];
    [self hy_hideRightButton];

    self.summaryLabel = [[UILabel alloc] init];
    self.summaryLabel.numberOfLines = 0;
    self.summaryLabel.textAlignment = NSTextAlignmentLeft;
    self.summaryLabel.textColor = HY_COLOR_TEXT_SECONDARY;
    self.summaryLabel.font = HY_FONT_BODY;
    self.summaryLabel.text = [self hy_summaryText];
    [self.hy_contentView addSubview:self.summaryLabel];

    [self.summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hy_contentView).offset(HY_MARGIN_XL);
        make.left.equalTo(self.hy_contentView).offset(HY_MARGIN_XL);
        make.right.equalTo(self.hy_contentView).offset(-HY_MARGIN_XL);
    }];
}

- (NSString *)hy_summaryText {
    NSString *sizeText = [[HYFileManagerService sharedInstance] formattedFileSize:self.documentItem.fileSize];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *modifiedText = [formatter stringFromDate:self.documentItem.modifiedDate];
    return [NSString stringWithFormat:@"文件名：%@\n类型：%@\n大小：%@\n更新时间：%@\n\nDay 3 会在这里接入统一预览能力。", self.documentItem.fileName, self.documentItem.typeDisplayName, sizeText, modifiedText];
}

@end
