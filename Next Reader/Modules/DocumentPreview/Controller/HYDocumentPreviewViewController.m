//
//  HYDocumentPreviewViewController.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYDocumentPreviewViewController.h"

#import <QuickLook/QuickLook.h>
#import <WebKit/WebKit.h>

#import "HYDocumentItem.h"
#import "HYMarkdownRenderer.h"
#import "HYTextReaderView.h"

@interface HYDocumentPreviewViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate, WKNavigationDelegate>

@property (nonatomic, strong) HYDocumentItem *documentItem;
@property (nonatomic, strong) UIView *previewContainerView;
@property (nonatomic, strong) QLPreviewController *quickLookController;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) HYTextReaderView *textReaderView;

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

    self.previewContainerView = [[UIView alloc] init];
    self.previewContainerView.backgroundColor = HY_COLOR_BG_WHITE;
    [self.hy_contentView addSubview:self.previewContainerView];

    [self.previewContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.hy_contentView);
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

- (void)hy_showQuickLookPreview {
    [self hy_resetPreviewSubviews];

    self.quickLookController = [[QLPreviewController alloc] init];
    self.quickLookController.dataSource = self;
    self.quickLookController.delegate = self;
    [self addChildViewController:self.quickLookController];
    [self.previewContainerView addSubview:self.quickLookController.view];

    [self.quickLookController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.previewContainerView);
    }];

    [self.quickLookController didMoveToParentViewController:self];
    [self.quickLookController reloadData];
}

- (void)hy_showMarkdownPreview {
    [self hy_resetPreviewSubviews];

    NSError *readError = nil;
    NSString *markdown = [NSString stringWithContentsOfFile:self.documentItem.filePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&readError];
    if (markdown == nil) {
        [self hy_showEmptyViewWithImage:nil title:@"Markdown 解析失败" message:readError.localizedDescription ?: @"无法读取当前文件内容。"];
        return;
    }

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    self.webView.navigationDelegate = self;
    self.webView.backgroundColor = HY_COLOR_BG_WHITE;
    self.webView.opaque = NO;
    [self.previewContainerView addSubview:self.webView];

    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.previewContainerView);
    }];

    NSString *htmlString = [HYMarkdownRenderer HTMLStringFromMarkdown:markdown title:self.documentItem.fileName];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (void)hy_showTextReader {
    [self hy_resetPreviewSubviews];

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
        [self hy_showEmptyViewWithImage:nil title:@"文本解析失败" message:readError.localizedDescription ?: @"无法读取当前文件内容。"];
        return;
    }

    self.textReaderView = [[HYTextReaderView alloc] init];
    [self.previewContainerView addSubview:self.textReaderView];

    [self.textReaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.previewContainerView);
    }];

    [self.textReaderView updateWithText:text];
}

- (void)hy_resetPreviewSubviews {
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

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:self.documentItem.filePath];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self hy_showEmptyViewWithImage:nil title:@"页面渲染失败" message:error.localizedDescription ?: @"WKWebView 无法展示当前内容。"];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self hy_showEmptyViewWithImage:nil title:@"页面加载失败" message:error.localizedDescription ?: @"WKWebView 无法加载当前内容。"];
}

@end
