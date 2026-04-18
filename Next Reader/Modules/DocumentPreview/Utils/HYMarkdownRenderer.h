//
//  HYMarkdownRenderer.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYMarkdownRenderer : NSObject

+ (NSString *)HTMLStringFromMarkdown:(NSString *)markdown title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
