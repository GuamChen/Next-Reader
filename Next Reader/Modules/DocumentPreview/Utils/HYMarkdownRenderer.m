//
//  HYMarkdownRenderer.m
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import "HYMarkdownRenderer.h"

@implementation HYMarkdownRenderer

+ (NSString *)HTMLStringFromMarkdown:(NSString *)markdown title:(NSString *)title {
    NSMutableString *bodyHTML = [NSMutableString string];
    BOOL isInCodeBlock = NO;
    NSMutableString *codeBlockContent = [NSMutableString string];

    NSArray<NSString *> *lines = [markdown componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        if ([line hasPrefix:@"```"]) {
            if (isInCodeBlock) {
                [bodyHTML appendFormat:@"<pre><code>%@</code></pre>", [self hy_escapeHTML:codeBlockContent]];
                [codeBlockContent setString:@""];
            }
            isInCodeBlock = !isInCodeBlock;
            continue;
        }

        if (isInCodeBlock) {
            [codeBlockContent appendFormat:@"%@\n", line];
            continue;
        }

        NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (trimmedLine.length == 0) {
            [bodyHTML appendString:@"<div class='spacer'></div>"];
            continue;
        }

        if ([trimmedLine hasPrefix:@"### "]) {
            [bodyHTML appendFormat:@"<h3>%@</h3>", [self hy_escapeHTML:[trimmedLine substringFromIndex:4]]];
        } else if ([trimmedLine hasPrefix:@"## "]) {
            [bodyHTML appendFormat:@"<h2>%@</h2>", [self hy_escapeHTML:[trimmedLine substringFromIndex:3]]];
        } else if ([trimmedLine hasPrefix:@"# "]) {
            [bodyHTML appendFormat:@"<h1>%@</h1>", [self hy_escapeHTML:[trimmedLine substringFromIndex:2]]];
        } else if ([trimmedLine hasPrefix:@"> "]) {
            [bodyHTML appendFormat:@"<blockquote>%@</blockquote>", [self hy_escapeHTML:[trimmedLine substringFromIndex:2]]];
        } else if ([trimmedLine hasPrefix:@"- "] || [trimmedLine hasPrefix:@"* "]) {
            [bodyHTML appendFormat:@"<p class='bullet'>• %@</p>", [self hy_escapeHTML:[trimmedLine substringFromIndex:2]]];
        } else if ([trimmedLine isEqualToString:@"---"]) {
            [bodyHTML appendString:@"<hr />"];
        } else {
            [bodyHTML appendFormat:@"<p>%@</p>", [self hy_escapeInlineMarkdown:[self hy_escapeHTML:trimmedLine]]];
        }
    }

    NSString *pageTitle = [self hy_escapeHTML:title ?: @"Markdown"];
    return [NSString stringWithFormat:@"<!DOCTYPE html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'><title>%@</title><style>body{font-family:-apple-system,BlinkMacSystemFont,'PingFang SC',sans-serif;background:#FCFCFD;color:#1A1A1A;padding:20px;line-height:1.8;}h1,h2,h3{margin:20px 0 12px;font-weight:600;}h1{font-size:28px;}h2{font-size:24px;}h3{font-size:20px;}p{margin:0 0 12px;font-size:16px;word-break:break-word;}blockquote{margin:12px 0;padding:10px 14px;border-left:4px solid #0052D9;background:#F3F7FF;color:#334155;}pre{margin:12px 0;padding:14px;border-radius:12px;background:#111827;color:#E5E7EB;overflow:auto;font-family:'Menlo','SFMono-Regular',monospace;font-size:14px;}code{font-family:'Menlo','SFMono-Regular',monospace;}hr{border:none;border-top:1px solid #E5E7EB;margin:20px 0;}.bullet{padding-left:2px;}.spacer{height:8px;}strong{font-weight:700;}em{font-style:italic;}</style></head><body>%@</body></html>", pageTitle, bodyHTML];
}

+ (NSString *)hy_escapeHTML:(NSString *)text {
    NSString *escaped = [text stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    return escaped;
}

+ (NSString *)hy_escapeInlineMarkdown:(NSString *)text {
    NSError *boldError = nil;
    NSRegularExpression *boldRegex = [NSRegularExpression regularExpressionWithPattern:@"\\*\\*(.+?)\\*\\*" options:0 error:&boldError];
    NSString *result = boldError == nil ? [boldRegex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@"<strong>$1</strong>"] : text;

    NSError *italicError = nil;
    NSRegularExpression *italicRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)" options:0 error:&italicError];
    if (italicError == nil) {
        result = [italicRegex stringByReplacingMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@"<em>$1</em>"];
    }

    return result;
}

@end
