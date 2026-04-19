//
//  HYSettingViewController.m
//  Next Reader
//
//  Created by Gavin on 2026/4/16.
//

#import "HYSettingViewController.h"

#import "HYFileManagerService.h"

typedef NS_ENUM(NSInteger, HYSettingActionType) {
    HYSettingActionTypeClearCache = 0,
    HYSettingActionTypeClearTemp,
    HYSettingActionTypeClearAllManagedCaches,
};

@interface HYSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *actions;

@end

@implementation HYSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hy_setNavTitle:@"设置"];
    [self hy_setupTableView];
    [self hy_reloadActions];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hy_reloadActions];
}

- (void)hy_setupTableView {
    UITableViewStyle tableViewStyle = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) {
        tableViewStyle = UITableViewStyleInsetGrouped;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:tableViewStyle];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 68.0f;
    self.tableView.estimatedRowHeight = 0.0f;
    self.tableView.estimatedSectionHeaderHeight = 0.0f;
    self.tableView.estimatedSectionFooterHeight = 0.0f;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.hy_contentView addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.hy_contentView);
    }];
}

- (void)hy_reloadActions {
    HYFileManagerService *fileManagerService = [HYFileManagerService sharedInstance];
    NSString *cacheSizeText = [fileManagerService formattedFileSize:[fileManagerService cacheDirectorySize]];
    NSString *tempSizeText = [fileManagerService formattedFileSize:[fileManagerService tempDirectorySize]];
    NSString *allSizeText = [fileManagerService formattedFileSize:[fileManagerService totalManagedCacheSize]];

    self.actions = @[
        @{@"title": @"清理 Cache", @"detail": [NSString stringWithFormat:@"删除文档缓存目录中的内容 · 当前占用 %@", cacheSizeText], @"type": @(HYSettingActionTypeClearCache)},
        @{@"title": @"清理 Temp", @"detail": [NSString stringWithFormat:@"删除临时目录中的内容 · 当前占用 %@", tempSizeText], @"type": @(HYSettingActionTypeClearTemp)},
        @{@"title": @"清理全部缓存", @"detail": [NSString stringWithFormat:@"同时清理 Cache 和 Temp · 当前占用 %@", allSizeText], @"type": @(HYSettingActionTypeClearAllManagedCaches)},
    ];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"HYSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDictionary<NSString *, id> *item = self.actions[indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.textLabel.font = HY_FONT_MEDIUM(HY_FONT_SIZE_BODY);
    cell.textLabel.textColor = HY_COLOR_TEXT_PRIMARY;
    cell.detailTextLabel.text = item[@"detail"];
    cell.detailTextLabel.font = HY_FONT_SMALL;
    cell.detailTextLabel.textColor = HY_COLOR_TEXT_SECONDARY;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary<NSString *, id> *item = self.actions[indexPath.row];
    HYSettingActionType actionType = [item[@"type"] integerValue];
    [self hy_confirmActionType:actionType title:item[@"title"]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"沙盒管理";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Imported 目录中的文档不会被这里删除，“清理全部缓存”只会清理 Cache 和 Temp。";
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
        }

        NSString *sizeText = [[HYFileManagerService sharedInstance] formattedFileSize:clearedBytes];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hy_hideLoading];
            [self hy_reloadActions];
            [self hy_showToast:[NSString stringWithFormat:@"清理完成，释放 %@", sizeText]];
        });
    });
}

@end
