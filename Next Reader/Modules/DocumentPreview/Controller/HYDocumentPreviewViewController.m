//
//  HYDocumentPreviewViewController.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYDocumentPreviewViewController.h"

#import <PDFKit/PDFKit.h>
#import <QuickLook/QuickLook.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

#import "HYAsyncTaskManager.h"
#import "HYDocumentCacheManager.h"
#import "HYDocumentItem.h"
#import "HYFileManagerService.h"
#import "HYMarkdownRenderer.h"
#import "HYTextReaderView.h"

@interface HYDocumentPreviewViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate, WKNavigationDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) HYDocumentItem *documentItem;
@property (nonatomic, strong) UIView *previewContainerView;
@property (nonatomic, strong) PDFView *pdfView;
@property (nonatomic, strong) QLPreviewController *quickLookController;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) HYTextReaderView *textReaderView;
@property (nonatomic, strong) UIView *pdfToolbar;
@property (nonatomic, strong) UILabel *pdfProgressLabel;
@property (nonatomic, strong) UIView *quickLookToolbar;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

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
    [self hy_showLoadingWithMessage:@"正在准备预览..."];
    [[HYDocumentCacheManager sharedInstance] cachePreviewMetaForDocument:self.documentItem];
    [[HYDocumentCacheManager sharedInstance] cacheRecentPreviewForDocument:self.documentItem];

    self.previewContainerView = [HYUIBuildFactory viewWithBackgroundColor:HY_COLOR_BG_WHITE];
    [self.hy_contentView addSubview:self.previewContainerView];

    [self.previewContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.hy_contentView);
        make.bottom.equalTo(self.hy_contentView);
    }];

    [self hy_renderPreview];
}

- (void)hy_renderPreview {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.documentItem.filePath]) {
        [self hy_showEmptyViewWithImage:nil title:@"文件不存在" message:@"目标文件可能已被删除或移动。"];
        return;
    }

    [self hy_hideEmptyView];

    switch (self.documentItem.documentType) {
        case HYDocumentTypePDF:
            [self hy_showPDFPreview];
            break;

        case HYDocumentTypeWord:
        case HYDocumentTypeExcel:
        case HYDocumentTypePPT:
            [self hy_showQuickLookPreview];
            break;

        case HYDocumentTypeMarkdown:
            [self hy_showMarkdownPreview];
            break;

        case HYDocumentTypeText:
            [self hy_showTextReader];
            break;

        case HYDocumentTypeUnknown:
        default:
            [self hy_showQuickLookPreview];
            break;
    }
}

#pragma mark - Preview Routing

- (void)hy_showPDFPreview {
    [self hy_resetPreviewSubviews];
    [self hy_setupPDFToolbarIfNeeded];
    [self hy_hideQuickLookToolbar];

    PDFDocument *document = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:self.documentItem.filePath]];
    if (document == nil) {
        [self hy_showEmptyViewWithImage:nil title:@"PDF 加载失败" message:@"当前 PDF 文件无法解析。"];
        return;
    }

    self.pdfView = [[PDFView alloc] init];
    self.pdfView.autoScales = YES;
    self.pdfView.displayMode = kPDFDisplaySinglePageContinuous;
    self.pdfView.displayDirection = kPDFDisplayDirectionVertical;
    self.pdfView.document = document;
    [self.previewContainerView addSubview:self.pdfView];

    [self.pdfView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.previewContainerView);
        make.bottom.equalTo(self.pdfToolbar.mas_top);
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hy_pdfPageChanged:) name:PDFViewPageChangedNotification object:self.pdfView];
    [self hy_restorePDFProgress];
    [self hy_updatePDFProgressUI];
    [self hy_hideLoading];
}

- (void)hy_showQuickLookPreview {
    [self hy_resetPreviewSubviews];
    [self hy_setupQuickLookToolbarIfNeeded];
    [self hy_hidePDFToolbar];

    self.quickLookController = [[QLPreviewController alloc] init];
    self.quickLookController.dataSource = self;
    self.quickLookController.delegate = self;
    [self addChildViewController:self.quickLookController];
    [self.previewContainerView addSubview:self.quickLookController.view];

    [self.quickLookController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.previewContainerView);
        make.bottom.equalTo(self.quickLookToolbar.mas_top);
    }];

    [self.quickLookController didMoveToParentViewController:self];
    [self.quickLookController reloadData];
    [self hy_hideLoading];
}

- (void)hy_showMarkdownPreview {
    [self hy_resetPreviewSubviews];
    [self hy_hideQuickLookToolbar];
    [self hy_hidePDFToolbar];

    HY_WEAK_SELF
    dispatch_async([HYAsyncTaskManager sharedInstance].parseQueue, ^{
        @autoreleasepool {
            NSError *readError = nil;
            NSString *markdown = [NSString stringWithContentsOfFile:self.documentItem.filePath
                                                           encoding:NSUTF8StringEncoding
                                                              error:&readError];
            NSString *htmlString = markdown != nil ? [HYMarkdownRenderer HTMLStringFromMarkdown:markdown title:self.documentItem.fileName] : nil;

            dispatch_async(dispatch_get_main_queue(), ^{
                HY_STRONG_SELF
                if (!strongSelf) {
                    return;
                }
                if (htmlString == nil) {
                    [strongSelf hy_hideLoading];
                    [strongSelf hy_showEmptyViewWithImage:nil title:@"Markdown 解析失败" message:readError.localizedDescription ?: @"无法读取当前文件内容。"];
                    return;
                }

                WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
                strongSelf.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
                strongSelf.webView.navigationDelegate = strongSelf;
                strongSelf.webView.backgroundColor = HY_COLOR_BG_WHITE;
                strongSelf.webView.opaque = NO;
                [strongSelf.previewContainerView addSubview:strongSelf.webView];

                [strongSelf.webView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(strongSelf.previewContainerView);
                }];

                [strongSelf.webView loadHTMLString:htmlString baseURL:nil];
                [strongSelf hy_hideLoading];
            });
        }
    });
}

- (void)hy_showTextReader {
    [self hy_resetPreviewSubviews];
    [self hy_hideQuickLookToolbar];
    [self hy_hidePDFToolbar];

    HY_WEAK_SELF
    dispatch_async([HYAsyncTaskManager sharedInstance].parseQueue, ^{
        @autoreleasepool {
            NSError *readError = nil;
            NSString *text = [NSString stringWithContentsOfFile:self.documentItem.filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&readError];
            if (text == nil) {
                text = [NSString stringWithContentsOfFile:self.documentItem.filePath
                                                 encoding:NSUnicodeStringEncoding
                                                    error:&readError];
            }
            if (text == nil) {
                text = [NSString stringWithContentsOfFile:self.documentItem.filePath
                                                 encoding:NSUTF16StringEncoding
                                                    error:&readError];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                HY_STRONG_SELF
                if (!strongSelf) {
                    return;
                }
                if (text == nil) {
                    [strongSelf hy_hideLoading];
                    [strongSelf hy_showEmptyViewWithImage:nil title:@"文本解析失败" message:readError.localizedDescription ?: @"无法读取当前文件内容。"];
                    return;
                }

                strongSelf.textReaderView = [[HYTextReaderView alloc] init];
                [strongSelf.previewContainerView addSubview:strongSelf.textReaderView];

                [strongSelf.textReaderView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(strongSelf.previewContainerView);
                }];

                [strongSelf.textReaderView updateWithText:text cacheKey:strongSelf.documentItem.filePath];
                [strongSelf hy_hideLoading];
            });
        }
    });
}

- (void)hy_resetPreviewSubviews {
    if (self.pdfView != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:self.pdfView];
    }
    [self.pdfView removeFromSuperview];
    self.pdfView = nil;

    [self.quickLookController willMoveToParentViewController:nil];
    [self.quickLookController.view removeFromSuperview];
    [self.quickLookController removeFromParentViewController];
    self.quickLookController = nil;

    [self.webView removeFromSuperview];
    self.webView.navigationDelegate = nil;
    self.webView = nil;

    [self.textReaderView removeFromSuperview];
    self.textReaderView = nil;
}

#pragma mark - PDF Toolbar

- (void)hy_setupPDFToolbarIfNeeded {
    if (self.pdfToolbar != nil) {
        self.pdfToolbar.hidden = NO;
        return;
    }

    self.pdfToolbar = [HYUIBuildFactory viewWithBackgroundColor:HY_COLOR_BG_WHITE];
    [self.hy_contentView addSubview:self.pdfToolbar];

    UIView *separatorLine = [HYUIBuildFactory separatorLineWithColor:HY_COLOR_SEPARATOR];
    [self.pdfToolbar addSubview:separatorLine];

    UIButton *previousButton = [self hy_toolbarButtonWithTitle:@"上一页" action:@selector(hy_goToPreviousPDFPage)];
    UIButton *nextButton = [self hy_toolbarButtonWithTitle:@"下一页" action:@selector(hy_goToNextPDFPage)];
    UIButton *moreButton = [self hy_toolbarButtonWithTitle:@"更多" action:@selector(hy_showPDFMoreActions)];
    [self.pdfToolbar addSubview:previousButton];
    [self.pdfToolbar addSubview:nextButton];
    [self.pdfToolbar addSubview:moreButton];

    self.pdfProgressLabel = [HYUIBuildFactory labelWithFont:HY_FONT_MEDIUM(14.0f)
                                                  textColor:HY_COLOR_TEXT_PRIMARY
                                                  alignment:NSTextAlignmentCenter];
    [self.pdfToolbar addSubview:self.pdfProgressLabel];

    [self.pdfToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.hy_contentView);
        make.height.mas_equalTo(58.0f + HY_SAFE_BOTTOM_MARGIN);
    }];

    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.pdfToolbar);
        make.height.mas_equalTo(0.5f);
    }];

    [previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pdfToolbar);
        make.top.equalTo(self.pdfToolbar);
        make.width.mas_equalTo(80.0f);
        make.height.mas_equalTo(58.0f);
    }];

    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(moreButton.mas_left);
        make.top.equalTo(self.pdfToolbar);
        make.width.mas_equalTo(80.0f);
        make.height.mas_equalTo(58.0f);
    }];

    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pdfToolbar);
        make.top.equalTo(self.pdfToolbar);
        make.width.mas_equalTo(72.0f);
        make.height.mas_equalTo(58.0f);
    }];

    [self.pdfProgressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pdfToolbar);
        make.left.equalTo(previousButton.mas_right).offset(HY_MARGIN_XS);
        make.right.equalTo(nextButton.mas_left).offset(-HY_MARGIN_XS);
        make.height.mas_equalTo(58.0f);
    }];
}

- (void)hy_hidePDFToolbar {
    self.pdfToolbar.hidden = YES;
}

- (void)hy_pdfPageChanged:(NSNotification *)notification {
    [self hy_updatePDFProgressUI];
    [self hy_savePDFProgress];
}

- (void)hy_goToPreviousPDFPage {
    [self.pdfView goToPreviousPage:nil];
    [self hy_updatePDFProgressUI];
}

- (void)hy_goToNextPDFPage {
    [self.pdfView goToNextPage:nil];
    [self hy_updatePDFProgressUI];
}

- (void)hy_updatePDFProgressUI {
    PDFDocument *document = self.pdfView.document;
    PDFPage *currentPage = self.pdfView.currentPage;
    if (document == nil || currentPage == nil) {
        self.pdfProgressLabel.text = @"PDF";
        return;
    }

    NSInteger pageIndex = [document indexForPage:currentPage];
    NSInteger pageCount = document.pageCount;
    CGFloat progress = pageCount > 0 ? ((CGFloat)(pageIndex + 1) / (CGFloat)pageCount) : 0.0f;
    self.pdfProgressLabel.text = [NSString stringWithFormat:@"第 %ld / %ld 页  ·  %.0f%%", (long)(pageIndex + 1), (long)pageCount, progress * 100.0f];
}

- (void)hy_restorePDFProgress {
    NSString *defaultsKey = [self hy_pdfProgressDefaultsKey];
    NSInteger pageIndex = [[NSUserDefaults standardUserDefaults] integerForKey:defaultsKey];
    PDFDocument *document = self.pdfView.document;
    if (document == nil || pageIndex < 0 || pageIndex >= document.pageCount) {
        return;
    }

    PDFPage *page = [document pageAtIndex:pageIndex];
    if (page != nil) {
        [self.pdfView goToPage:page];
    }
}

- (void)hy_savePDFProgress {
    NSString *defaultsKey = [self hy_pdfProgressDefaultsKey];
    PDFDocument *document = self.pdfView.document;
    PDFPage *currentPage = self.pdfView.currentPage;
    if (defaultsKey == nil || document == nil || currentPage == nil) {
        return;
    }

    NSInteger pageIndex = [document indexForPage:currentPage];
    [[NSUserDefaults standardUserDefaults] setInteger:pageIndex forKey:defaultsKey];
}

- (NSString *)hy_pdfProgressDefaultsKey {
    if (HY_STRING_IS_EMPTY(self.documentItem.filePath)) {
        return nil;
    }
    return [NSString stringWithFormat:@"com.nextreader.pdf.progress.%@", self.documentItem.filePath];
}

- (void)hy_showPDFMoreActions {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PDF 工具"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"分享文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self hy_shareDocument];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"查看文件信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self hy_showDocumentInfo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"在系统中打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self hy_openDocumentExternally];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alertController.popoverPresentationController.sourceView = self.pdfToolbar;
        alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.pdfToolbar.bounds), 8.0f, 1.0f, 1.0f);
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - QuickLook Toolbar

- (void)hy_setupQuickLookToolbarIfNeeded {
    if (self.quickLookToolbar != nil) {
        self.quickLookToolbar.hidden = NO;
        return;
    }

    self.quickLookToolbar = [HYUIBuildFactory viewWithBackgroundColor:HY_COLOR_BG_WHITE];
    [self.hy_contentView addSubview:self.quickLookToolbar];

    UIView *separatorLine = [HYUIBuildFactory separatorLineWithColor:HY_COLOR_SEPARATOR];
    [self.quickLookToolbar addSubview:separatorLine];

    UIButton *shareButton = [self hy_toolbarButtonWithTitle:@"分享" action:@selector(hy_shareDocument)];
    UIButton *infoButton = [self hy_toolbarButtonWithTitle:@"信息" action:@selector(hy_showDocumentInfo)];
    UIButton *openButton = [self hy_toolbarButtonWithTitle:@"打开" action:@selector(hy_openDocumentExternally)];
    [self.quickLookToolbar addSubview:shareButton];
    [self.quickLookToolbar addSubview:infoButton];
    [self.quickLookToolbar addSubview:openButton];

    [self.quickLookToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.hy_contentView);
        make.height.mas_equalTo(58.0f + HY_SAFE_BOTTOM_MARGIN);
    }];

    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.quickLookToolbar);
        make.height.mas_equalTo(0.5f);
    }];

    NSArray<UIButton *> *buttons = @[shareButton, infoButton, openButton];
    [buttons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [buttons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.quickLookToolbar);
        make.height.mas_equalTo(58.0f);
    }];
}

- (UIButton *)hy_toolbarButtonWithTitle:(NSString *)title action:(SEL)action {
    return [HYUIBuildFactory buttonWithTitle:title
                                  titleColor:HY_COLOR_THEME
                                        font:HY_FONT_MEDIUM(15.0f)
                                      target:self
                                      action:action];
}

- (void)hy_hideQuickLookToolbar {
    self.quickLookToolbar.hidden = YES;
}

- (void)hy_shareDocument {
    NSURL *fileURL = [NSURL fileURLWithPath:self.documentItem.filePath];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIView *anchorView = [self hy_actionAnchorView];
        activityController.popoverPresentationController.sourceView = anchorView;
        activityController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(anchorView.bounds), 8.0f, 1.0f, 1.0f);
    }
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)hy_showDocumentInfo {
    NSString *sizeText = [[HYFileManagerService sharedInstance] formattedFileSize:self.documentItem.fileSize];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *modifiedText = [formatter stringFromDate:self.documentItem.modifiedDate];
    NSString *message = [NSString stringWithFormat:@"名称：%@\n类型：%@\n大小：%@\n更新时间：%@\n路径：%@", self.documentItem.fileName, self.documentItem.typeDisplayName, sizeText, modifiedText, self.documentItem.filePath];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"文档信息"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"复制路径" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = self.documentItem.filePath;
        [self hy_showToast:@"文件路径已复制"];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)hy_openDocumentExternally {
    NSURL *fileURL = [NSURL fileURLWithPath:self.documentItem.filePath];
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.documentInteractionController.delegate = self;
    UIView *anchorView = [self hy_actionAnchorView];
    BOOL didPresent = [self.documentInteractionController presentOptionsMenuFromRect:anchorView.bounds inView:anchorView animated:YES];
    if (!didPresent) {
        [self hy_showToast:@"系统中没有可用的打开方式"];
    }
}

- (UIView *)hy_actionAnchorView {
    if (self.pdfToolbar != nil && !self.pdfToolbar.hidden) {
        return self.pdfToolbar;
    }
    if (self.quickLookToolbar != nil && !self.quickLookToolbar.hidden) {
        return self.quickLookToolbar;
    }
    return self.view;
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:self.documentItem.filePath];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self hy_hideLoading];
    [self hy_showEmptyViewWithImage:nil title:@"页面渲染失败" message:error.localizedDescription ?: @"WKWebView 无法展示当前内容。"];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self hy_hideLoading];
    [self hy_showEmptyViewWithImage:nil title:@"页面加载失败" message:error.localizedDescription ?: @"WKWebView 无法加载当前内容。"];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self hy_hideLoading];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

@end
