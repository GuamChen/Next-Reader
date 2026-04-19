//
//  AppDelegate.m
//  Next Reader
//
//  Created by Gavin on 2026/4/15.
//

#import "AppDelegate.h"
#import "HYExternalDocumentRouter.h"
#import "HYMainTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // iOS 12 兼容：手动创建 window
    if (@available(iOS 13.0, *)) {
        // iOS 13+ 使用 SceneDelegate 处理
    } else {
        // iOS 12 及以下，手动创建 window
        UIScreen *screen = [UIScreen screens].firstObject;
        self.window = [[UIWindow alloc] initWithFrame:screen.bounds];
        self.window.backgroundColor = HY_COLOR_BG_WHITE;
        
        HYMainTabBarController *tabBarController = [[HYMainTabBarController alloc] init];
        self.window.rootViewController = tabBarController;
        [self.window makeKeyAndVisible];
    }
    
    // 全局配置
    [self setupGlobalAppearance];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0)) {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[HYExternalDocumentRouter sharedInstance] handleOpenURL:url options:options];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions API_AVAILABLE(ios(13.0)) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)setupGlobalAppearance {
    // 配置全局导航栏样式（系统导航栏）
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = HY_COLOR_BG_WHITE;
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: HY_COLOR_TEXT_PRIMARY,
            NSFontAttributeName: HY_FONT_MEDIUM(18)
        };
        
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
    } else {
        [[UINavigationBar appearance] setBarTintColor:HY_COLOR_BG_WHITE];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
            NSForegroundColorAttributeName: HY_COLOR_TEXT_PRIMARY,
            NSFontAttributeName: HY_FONT_MEDIUM(18)
        }];
    }
    
}
@end
