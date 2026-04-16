//
//  SceneDelegate.m
//  Next Reader
//
//  Created by Gavin on 2026/4/15.
///Users/gavin/Desktop/Next Reader/Next Reader/Base/Controller/HYDocumentListViewController.h

#import "SceneDelegate.h"
#import "HYDocumentListViewController.h"
#import "HYSettingViewController.h"
#import "HYMainTabBarController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
                 options:(UISceneConnectionOptions *)connectionOptions API_AVAILABLE(ios(13.0)) {
    
    // 创建 window 并设置根控制器
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.backgroundColor = HY_COLOR_BG_WHITE;
    
    // 设置根控制器
    HYMainTabBarController *tabBarController = [[HYMainTabBarController alloc] init];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
}

- (void)sceneDidDisconnect:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景被系统释放时调用
}

- (void)sceneDidBecomeActive:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景从非活跃状态变为活跃状态
}

- (void)sceneWillResignActive:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景即将从活跃状态变为非活跃状态
}

- (void)sceneWillEnterForeground:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景即将进入前台
}

- (void)sceneDidEnterBackground:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    // 场景进入后台时的清理工作
}

@end
