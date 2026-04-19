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
#import "HYAsyncTaskManager.h"
#import "HYDocumentCacheManager.h"
#import "HYFileManagerService.h"
#import "HYDocumentImportManager.h"

@interface HYDocumentListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<HYDocumentItem *> *dataSource;
@property (nonatomic, strong) HYDocumentImportManager *importManager;

@end

@implementation HYDocumentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hy_setNavTitle:@"我的文档"];
    [self hy_setRightButtonWithTitle:@"导入"
                               image:nil
                              target:self
                              action:@selector(importDocumentTapped)];

    self.importManager = [[HYDocumentImportManager alloc] init];
    HY_WEAK_SELF
    self.importManager.importCompletion = ^(NSArray<HYDocumentItem *> *items, NSError * _Nullable error, BOOL cancelled) {
        HY_STRONG_SELF
        if (!strongSelf) {
            return;
        }

        [strongSelf hy_hideLoading];
        if (cancelled) {
            [strongSelf hy_showToast:@"已取消导入" duration:1.2];
            return;
        }

        if (items.count > 0) {
            [strongSelf hy_applyImportedItemsIncrementally:items];
            [strongSelf hy_showToast:[NSString stringWithFormat:@"成功导入 %lu 个文件", (unsigned long)items.count]];
        } else {
            [strongSelf hy_loadDocuments];
            [strongSelf hy_showToast:[strongSelf hy_importFailureMessageForError:error]];
        }
    };

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

    dispatch_async([HYAsyncTaskManager sharedInstance].ioQueue, ^{
        @autoreleasepool {
            NSArray<HYDocumentItem *> *documents = [[HYFileManagerService sharedInstance] fetchLocalDocuments];
            for (HYDocumentItem *item in documents) {
                [[HYDocumentCacheManager sharedInstance] cachePreviewMetaForDocument:item];
            }
            [[HYDocumentCacheManager sharedInstance] clearTempCacheIfNeeded];

            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataSource = documents;
                [self hy_hideLoading];
                [self.tableView reloadData];
                [self hy_updateEmptyState];
            });
        }
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
    [self hy_showLoadingWithMessage:@"正在准备导入..."];
    [self.importManager presentDocumentPickerFromViewController:self];
}

- (void)hy_applyImportedItemsIncrementally:(NSArray<HYDocumentItem *> *)items {
    if (items.count == 0) {
        [self hy_loadDocuments];
        return;
    }

    NSArray<HYDocumentItem *> *sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(HYDocumentItem *obj1, HYDocumentItem *obj2) {
        return [obj2.modifiedDate compare:obj1.modifiedDate];
    }];

    NSMutableArray<HYDocumentItem *> *mergedDataSource = [self.dataSource mutableCopy] ?: [NSMutableArray array];
    NSIndexSet *duplicateIndexes = [mergedDataSource indexesOfObjectsPassingTest:^BOOL(HYDocumentItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (HYDocumentItem *newItem in sortedItems) {
            if ([obj.filePath isEqualToString:newItem.filePath]) {
                return YES;
            }
        }
        return NO;
    }];
    if (duplicateIndexes.count > 0) {
        [mergedDataSource removeObjectsAtIndexes:duplicateIndexes];
    }

    NSIndexSet *insertionIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sortedItems.count)];
    [mergedDataSource insertObjects:sortedItems atIndexes:insertionIndexes];

    BOOL canPerformIncrementalInsert = self.dataSource.count > 0 && duplicateIndexes.count == 0;
    self.dataSource = mergedDataSource.copy;
    [self hy_updateEmptyState];

    if (!canPerformIncrementalInsert) {
        [self.tableView reloadData];
        return;
    }

    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    for (NSUInteger index = 0; index < sortedItems.count; index++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }

    if (@available(iOS 11.0, *)) {
        [self.tableView performBatchUpdates:^{
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        } completion:nil];
    } else {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
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

- (NSString *)hy_importFailureMessageForError:(NSError *)error {
    switch (error.code) {
        case HYDocumentImportErrorCodeTooLarge:
            return @"导入失败：文件过大，单个文件不能超过 200MB";
        case HYDocumentImportErrorCodeUnsupportedType:
            return @"导入失败：当前文件类型不支持";
        case HYDocumentImportErrorCodeUnreadable:
            return @"导入失败：文件无读取权限或不可访问";
        case HYDocumentImportErrorCodeMissingURL:
            return @"导入失败：没有拿到有效文件";
        case HYDocumentImportErrorCodeCopyFailed:
            return @"导入失败：复制到沙盒时出错";
        default:
            return error.localizedDescription ?: @"导入失败，请稍后重试";
    }
}

@end
