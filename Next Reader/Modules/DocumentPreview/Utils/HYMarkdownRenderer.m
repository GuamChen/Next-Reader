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
    NSString *codeBlockLanguage = nil;
    BOOL isInList = NO;

    NSArray<NSString *> *lines = [markdown componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        if ([line hasPrefix:@"```"]) {
            if (isInCodeBlock) {
                [bodyHTML appendFormat:@"<div class='code-block'><div class='code-header'>%@</div><pre><code>%@</code></pre></div>", codeBlockLanguage.length > 0 ? [self hy_escapeHTML:codeBlockLanguage] : @"CODE", [self hy_escapeHTML:codeBlockContent]];
                [codeBlockContent setString:@""];
                codeBlockLanguage = nil;
            }
            if (!isInCodeBlock && line.length > 3) {
                codeBlockLanguage = [[line substringFromIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
            if (isInList) {
                [bodyHTML appendString:@"</ul>"];
                isInList = NO;
            }
            [bodyHTML appendString:@"<div class='spacer'></div>"];
            continue;
        }

        if ([trimmedLine hasPrefix:@"### "]) {
            if (isInList) {
                [bodyHTML appendString:@"</ul>"];
                isInList = NO;
            }
            [bodyHTML appendFormat:@"<h3>%@</h3>", [self hy_escapeHTML:[trimmedLine substringFromIndex:4]]];
        } else if ([trimmedLine hasPrefix:@"## "]) {
            if (isInList) {
                [bodyHTML appendString:@"</ul>"];
                isInList = NO;
            }
            [bodyHTML appendFormat:@"<h2>%@</h2>", [self hy_escapeHTML:[trimmedLine substringFromIndex:3]]];
        } else if ([trimmedLine hasPrefix:@"# "]) {
            if (isInList) {
                [bodyHTML appendString:@"</ul>"];
                isInList = NO;
            }
            [bodyHTML appendFormat:@"<h1>%@</h1>", [self hy_escapeHTML:[trimmedLine substringFromIndex:2]]];
        } else if ([trimmedLine hasPrefix:@"> "]) {
            if (isInList) {
                [bodyHTML appendString:@"</ul>"];
                isInList = NO;
            }
            [bodyHTML appendFormat:@"<blockquote>%@</blockquote>", [self hy_escapeHTML:[trimmedLine substringFromIndex:2]]];
        } else if ([trimmedLine hasPrefix:@"- "] || [trimmedLine hasPrefix:@"* "]) {
            if (!isInList) {
                [bodyHTML appendString:@"<ul>"];
                isInList = YES;
            }
            [bodyHTML appendFormat:@"<li>%@</li>", [self hy_escapeInlineMarkdown:[self hy_escapeHTML:[trimmedLine substringFromIndex:2]]]];
        } else if ([self hy_isOrderedListItem:trimmedLine]) {
            if (!isInList) {
                [bodyHTML appendString:@"<ul class='ordered-list'>"];
                isInList = YES;
            }
            NSString *listBody = [trimmedLine substringFromIndex:[self hy_prefixLengthForOrderedListItem:trimmedLine]];
            [bodyHTML appendFormat:@"<li>%@</li>", [self hy_escapeInlineMarkdown:[self hy_escapeHTML:listBody]]];
        } else if ([trimmedLine isEqualToString:@"---"]) {
            if (isInList) {
                [bodyHTML appendString:@"</ul>"];
                isInList = NO;
            }
            [bodyHTML appendString:@"<hr />"];
        } else {
            if (isInList) {
                [bodyHTML appendString:@"</ul>"];
                isInList = NO;
            }
            [bodyHTML appendFormat:@"<p>%@</p>", [self hy_escapeInlineMarkdown:[self hy_escapeHTML:trimmedLine]]];
        }
    }

    if (isInList) {
        [bodyHTML appendString:@"</ul>"];
    }

    NSString *pageTitle = [self hy_escapeHTML:title ?: @"Markdown"];
    return [NSString stringWithFormat:@"<!DOCTYPE html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'><title>%@</title><style>body{font-family:-apple-system,BlinkMacSystemFont,'PingFang SC',sans-serif;background:linear-gradient(180deg,#FCFCFD 0%%,#F7F9FC 100%%);color:#1A1A1A;padding:20px;line-height:1.85;}h1,h2,h3{margin:22px 0 12px;font-weight:700;letter-spacing:-0.02em;}h1{font-size:30px;}h2{font-size:24px;}h3{font-size:20px;}p{margin:0 0 14px;font-size:16px;word-break:break-word;}blockquote{margin:14px 0;padding:12px 16px;border-left:4px solid #0052D9;background:#F3F7FF;color:#334155;border-radius:0 10px 10px 0;}ul{margin:0 0 14px 0;padding-left:24px;}li{margin:6px 0;font-size:16px;}.ordered-list{list-style:decimal;}.code-block{margin:14px 0;border-radius:14px;overflow:hidden;box-shadow:0 8px 24px rgba(17,24,39,0.12);}.code-header{padding:8px 14px;background:#0F172A;color:#93C5FD;font-size:12px;font-family:'Menlo','SFMono-Regular',monospace;letter-spacing:0.08em;}.code-block pre{margin:0;padding:16px;background:#111827;color:#E5E7EB;overflow:auto;font-family:'Menlo','SFMono-Regular',monospace;font-size:14px;}code{padding:2px 5px;border-radius:6px;background:#EEF2FF;color:#4338CA;font-family:'Menlo','SFMono-Regular',monospace;font-size:0.92em;}pre code{padding:0;background:transparent;color:inherit;}a{color:#0052D9;text-decoration:none;border-bottom:1px solid rgba(0,82,217,0.2);}hr{border:none;border-top:1px solid #E5E7EB;margin:22px 0;}.spacer{height:10px;}strong{font-weight:700;}em{font-style:italic;}</style></head><body>%@</body></html>", pageTitle, bodyHTML];
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

    NSError *inlineCodeError = nil;
    NSRegularExpression *inlineCodeRegex = [NSRegularExpression regularExpressionWithPattern:@"`([^`]+)`" options:0 error:&inlineCodeError];
    if (inlineCodeError == nil) {
        result = [inlineCodeRegex stringByReplacingMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@"<code>$1</code>"];
    }

    NSError *linkError = nil;
    NSRegularExpression *linkRegex = [NSRegularExpression regularExpressionWithPattern:@"\\[([^\\]]+)\\]\\(([^\\)]+)\\)" options:0 error:&linkError];
    if (linkError == nil) {
        result = [linkRegex stringByReplacingMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@"<a href=\"$2\">$1</a>"];
    }

    return result;
}

+ (BOOL)hy_isOrderedListItem:(NSString *)text {
    NSUInteger prefixLength = [self hy_prefixLengthForOrderedListItem:text];
    return prefixLength > 0 && prefixLength < text.length;
}

+ (NSUInteger)hy_prefixLengthForOrderedListItem:(NSString *)text {
    NSCharacterSet *decimalSet = [NSCharacterSet decimalDigitCharacterSet];
    NSUInteger index = 0;
    while (index < text.length && [decimalSet characterIsMember:[text characterAtIndex:index]]) {
        index += 1;
    }
    if (index == 0 || index + 1 >= text.length) {
        return 0;
    }
    if ([text characterAtIndex:index] != '.' || [text characterAtIndex:index + 1] != ' ') {
        return 0;
    }
    return index + 2;
}

@end
