//
//  HYTextReaderView.h
//  Next Reader
//
//  Created by Codex on 2026/4/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYTextReaderView : UIView

- (void)updateWithText:(NSString *)text cacheKey:(NSString *)cacheKey;

@end

NS_ASSUME_NONNULL_END
