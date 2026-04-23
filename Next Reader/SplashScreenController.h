//
//  ViewController.h
//  Next Reader
//
//  Created by Gavin on 2026/4/15.
//

#import <UIKit/UIKit.h>

@interface SplashScreenController : UIViewController
@property (nonatomic, assign) float  duration;


- (void)showInWindow:(UIWindow *)window completion:(void(^)(void))completio;
@end

