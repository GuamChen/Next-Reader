//
//  HYDocumentListViewController.m
//  Next Reader
//
//  Created by Gavin on 2026/4/16.
//

#import "HYDocumentListViewController.h"

#import "HYDocumentItem.h"
#import "HYDocumentListCell.h"
#import "HYDocumentPreviewViewController.h"
#import "HYFileManagerService.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface HYDocumentListViewController () <UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<HYDocumentItem *> *dataSource;

@end

@implementation HYDocumentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hy_setNavTitle:@"我的文档"];
    [self hy_setRightButtonWithTitle:@"导入"
                               image:nil
                              target:self
                              action:@selector(importDocumentTapped)];

    [self hy_setupTableView];
}

- (void)hy_viewWillAppearForFirstTime {
    [self hy_loadDocuments];
}

- (void)hy_setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = HY_COLOR_BG_WHITE;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 72.0f;
    self.tableView.estimatedRowHeight = 0.0f;
    self.tableView.estimatedSectionHeaderHeight = 0.0f;
    self.tableView.estimatedSectionFooterHeight = 0.0f;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.tableView registerClass:[HYDocumentListCell class] forCellReuseIdentifier:[HYDocumentListCell reuseIdentifier]];
    [self.hy_contentView addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.hy_contentView);
    }];
}

- (void)hy_loadDocuments {
    [self hy_showLoadingWithMessage:@"正在扫描本地文档..."];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<HYDocumentItem *> *documents = [[HYFileManagerService sharedInstance] fetchLocalDocuments];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataSource = documents;
            [self hy_hideLoading];
            [self.tableView reloadData];
            [self hy_updateEmptyState];
        });
    });
}

- (void)hy_updateEmptyState {
    if (self.dataSource.count > 0) {
        [self hy_hideEmptyView];
        return;
    }

    [self hy_showEmptyViewWithImage:nil
                              title:@"还没有可阅读的本地文档"
                            message:@"当前沙盒中的 Documents / Imported / Inbox 目录为空。点击右上角“导入”添加文档。"];
}

- (void)importDocumentTapped {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeItem]
                                                                                                    inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    if (@available(iOS 11.0, *)) {
        picker.allowsMultipleSelection = YES;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYDocumentListCell *cell = [tableView dequeueReusableCellWithIdentifier:[HYDocumentListCell reuseIdentifier] forIndexPath:indexPath];
    [cell configWithItem:self.dataSource[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    HYDocumentItem *item = self.dataSource[indexPath.row];
    HYDocumentPreviewViewController *previewController = [[HYDocumentPreviewViewController alloc] initWithDocumentItem:item];
    previewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) {
        return;
    }

    [self hy_showLoadingWithMessage:@"正在导入文档..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger successCount = 0;
        NSMutableArray<NSString *> *failedNames = [NSMutableArray array];

        for (NSURL *url in urls) {
            NSError *importError = nil;
            BOOL success = [[HYFileManagerService sharedInstance] importDocumentAtURL:url error:&importError];
            if (success) {
                successCount += 1;
            } else {
                NSString *failedName = url.lastPathComponent ?: @"未知文件";
                [failedNames addObject:failedName];
                HYLog(@"Import failed for %@: %@", failedName, importError.localizedDescription);
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self hy_hideLoading];
            [self hy_loadDocuments];

            if (successCount > 0) {
                [self hy_showToast:[NSString stringWithFormat:@"成功导入 %lu 个文件", (unsigned long)successCount]];
            } else {
                [self hy_showToast:@"导入失败，文件类型不支持或拷贝失败"];
            }

            if (failedNames.count > 0) {
                HYLog(@"Failed imports: %@", failedNames);
            }
        });
    });
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self hy_showToast:@"已取消导入" duration:1.2];
}

@end
