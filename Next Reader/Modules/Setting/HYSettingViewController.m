//
//  HYSettingViewController.m
//  Next Reader
//
//  Created by Gavin on 2026/4/16.
//

#import "HYSettingViewController.h"

#import "HYBaseLabel.h"
#import "HYFileManagerService.h"
#import "HYFontManager.h"
#import "HYFontSettingViewController.h"

typedef NS_ENUM(NSInteger, HYSettingActionType) {
    HYSettingActionTypeFontSize = 0,
    HYSettingActionTypeClearCache,
    HYSettingActionTypeClearTemp,
    HYSettingActionTypeClearAllManagedCaches,
};

@interface HYSettingMenuCell : UITableViewCell

@property (nonatomic, strong) HYBaseLabel *titleLabel;
@property (nonatomic, strong) HYBaseLabel *detailLabel;

- (void)configWithTitle:(NSString *)title detail:(NSString *)detail;

@end

@implementation HYSettingMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = HY_COLOR_BG_WHITE;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        _titleLabel = [[HYBaseLabel alloc] init];
        _titleLabel.hy_baseFont = HY_FONT_MEDIUM(HY_FONT_SIZE_BODY);
        _titleLabel.textColor = HY_COLOR_TEXT_PRIMARY;
        [self.contentView addSubview:_titleLabel];

        _detailLabel = [[HYBaseLabel alloc] init];
        _detailLabel.hy_baseFont = HY_FONT_SMALL;
        _detailLabel.textColor = HY_COLOR_TEXT_SECONDARY;
        _detailLabel.numberOfLines = 2;
        [self.contentView addSubview:_detailLabel];

        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(HY_MARGIN_SM);
            make.left.equalTo(self.contentView).offset(HY_MARGIN_MD);
            make.right.equalTo(self.contentView).offset(-44.0f);
        }];

        [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(6.0f);
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.titleLabel);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-HY_MARGIN_SM);
        }];
    }
    return self;
}

- (void)configWithTitle:(NSString *)title detail:(NSString *)detail {
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
}

@end

@interface HYSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *sections;

@end

@implementation HYSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hy_setNavTitle:@"设置"];
    [self hy_setupTableView];
    [self hy_reloadSections];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hy_fontSizeDidChangeNotification:)
                                                 name:HYFontSizeDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hy_reloadSections];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hy_setupTableView {
    UITableViewStyle tableViewStyle = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) {
        tableViewStyle = UITableViewStyleInsetGrouped;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:tableViewStyle];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 78.0f;
    self.tableView.estimatedRowHeight = 0.0f;
    self.tableView.estimatedSectionHeaderHeight = 0.0f;
    self.tableView.estimatedSectionFooterHeight = 0.0f;
    [self.tableView registerClass:[HYSettingMenuCell class] forCellReuseIdentifier:@"HYSettingMenuCell"];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.hy_contentView addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.hy_contentView);
    }];
}

- (void)hy_reloadSections {
    HYFileManagerService *fileManagerService = [HYFileManagerService sharedInstance];
    HYFontManager *fontManager = [HYFontManager sharedManager];
    NSString *cacheSizeText = [fileManagerService formattedFileSize:[fileManagerService cacheDirectorySize]];
    NSString *tempSizeText = [fileManagerService formattedFileSize:[fileManagerService tempDirectorySize]];
    NSString *allSizeText = [fileManagerService formattedFileSize:[fileManagerService totalManagedCacheSize]];

    self.sections = @[
        @{
            @"title": @"阅读设置",
            @"footer": @"字体大小会作用于文档列表、设置菜单和 TabBar 标题；文档阅读器内的 PDF 内容不受本次设置影响。",
            @"items": @[
                @{@"title": @"字体大小", @"detail": [NSString stringWithFormat:@"当前档位：%@", [fontManager displayTitleForScale:fontManager.currentScale]], @"type": @(HYSettingActionTypeFontSize)},
            ]
        },
        @{
            @"title": @"沙盒管理",
            @"footer": @"Imported 目录中的文档不会被这里删除，“清理全部缓存”只会清理 Cache 和 Temp。",
            @"items": @[
                @{@"title": @"清理 Cache", @"detail": [NSString stringWithFormat:@"删除文档缓存目录中的内容 · 当前占用 %@", cacheSizeText], @"type": @(HYSettingActionTypeClearCache)},
                @{@"title": @"清理 Temp", @"detail": [NSString stringWithFormat:@"删除临时目录中的内容 · 当前占用 %@", tempSizeText], @"type": @(HYSettingActionTypeClearTemp)},
                @{@"title": @"清理全部缓存", @"detail": [NSString stringWithFormat:@"同时清理 Cache 和 Temp · 当前占用 %@", allSizeText], @"type": @(HYSettingActionTypeClearAllManagedCaches)},
            ]
        }
    ];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section][@"items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYSettingMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYSettingMenuCell" forIndexPath:indexPath];
    NSDictionary<NSString *, id> *item = self.sections[indexPath.section][@"items"][indexPath.row];
    [cell configWithTitle:item[@"title"] detail:item[@"detail"]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary<NSString *, id> *item = self.sections[indexPath.section][@"items"][indexPath.row];
    HYSettingActionType actionType = [item[@"type"] integerValue];
    if (actionType == HYSettingActionTypeFontSize) {
        HYFontSettingViewController *fontSettingViewController = [[HYFontSettingViewController alloc] init];
        [self.navigationController pushViewController:fontSettingViewController animated:YES];
        return;
    }
    [self hy_confirmActionType:actionType title:item[@"title"]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section][@"title"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.sections[section][@"footer"];
}

#pragma mark - Actions

- (void)hy_confirmActionType:(HYSettingActionType)actionType title:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:@"该操作会删除对应目录下的所有内容，且无法恢复。"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认清理" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self hy_executeActionType:actionType];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 1.0f, 1.0f);
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)hy_executeActionType:(HYSettingActionType)actionType {
    [self hy_showLoadingWithMessage:@"正在清理目录..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        unsigned long long clearedBytes = 0;
        switch (actionType) {
            case HYSettingActionTypeClearCache:
                clearedBytes = [[HYFileManagerService sharedInstance] clearCacheDirectory];
                break;
            case HYSettingActionTypeClearTemp:
                clearedBytes = [[HYFileManagerService sharedInstance] clearTempDirectory];
                break;
            case HYSettingActionTypeClearAllManagedCaches:
                clearedBytes = [[HYFileManagerService sharedInstance] clearAllManagedCaches];
                break;
            case HYSettingActionTypeFontSize:
                break;
        }

        NSString *sizeText = [[HYFileManagerService sharedInstance] formattedFileSize:clearedBytes];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hy_hideLoading];
            [self hy_reloadSections];
            [self hy_showToast:[NSString stringWithFormat:@"清理完成，释放 %@", sizeText]];
        });
    });
}

- (void)hy_fontSizeDidChangeNotification:(NSNotification *)notification {
    [self hy_reloadSections];
    [UIView transitionWithView:self.tableView
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
        [self.tableView reloadData];
    } completion:nil];
}

@end
