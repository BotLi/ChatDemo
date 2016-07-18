//
//  AppDelegate.m
//  chatDemo
//
//  Created by Li Bot on 2016/6/25.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "AppDelegate.h"
#import "RoomTableViewController.h"
#import "ChatTableViewController.h"
#import "CustomTabBarController.h"
#import "UIImage+FitInSize.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    RoomTableViewController *roomView = [[RoomTableViewController alloc] init];
    roomView.title = @"Chat Room";
    UINavigationController *navRoom = [[UINavigationController alloc] initWithRootViewController:roomView];
    navRoom.tabBarItem.image = [[UIImage imageNamed:@"ChatRoom"] fitInSize:CGSizeMake(40, 40)];
    
    UserTableViewController *userView = [[UserTableViewController alloc] initWithRoomID:nil];
    userView.title = @"Users";
    UINavigationController *navUser = [[UINavigationController alloc] initWithRootViewController:userView];
    navUser.tabBarItem.image = [[UIImage imageNamed:@"Users"] fitInSize:CGSizeMake(40, 40)];
    
    ChatTableViewController *chatView = [[ChatTableViewController alloc] init];
    chatView.title = @"Chats";
    UINavigationController *navChat = [[UINavigationController alloc] initWithRootViewController:chatView];
    navChat.tabBarItem.image = [[UIImage imageNamed:@"Chats"] fitInSize:CGSizeMake(40, 40)];
    
    self.tabBarController = [[CustomTabBarController alloc] init];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navRoom, navUser,navChat ,nil];
    
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    
    [AKLocationManager startLocatingWithUpdateBlock:^(CLLocation *location){
        
    }failedBlock:^(NSError *error){
        
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
    return [[FIRAuthUI authUI] handleOpenURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
}
//for ios8
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FIRAuthUI authUI] handleOpenURL:url sourceApplication:sourceApplication];
}
@end
