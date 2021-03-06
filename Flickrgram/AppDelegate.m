//
//  AppDelegate.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/16/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoTableViewController.h"
#import "UserProfileViewController.h"
#import "PhotoMapViewController.h"
#import "Utilities.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
  PhotoTableViewController *_viewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [[UINavigationBar appearance] setBarTintColor:[UIColor darkBlueColor]];
  [[UINavigationBar appearance] setTranslucent:NO];
  NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
  [[UINavigationBar appearance] setTitleTextAttributes:attributes];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  UITabBarController *tabBarController    = [[UITabBarController alloc] init];
  self.window.rootViewController          = tabBarController;
  [self.window makeKeyAndVisible];
  
  // create Home Feed viewController & navController
  _viewController                          = [[PhotoTableViewController alloc] init];
  UINavigationController *homeFeedNavCtrl  = [[UINavigationController alloc] initWithRootViewController:_viewController];
  homeFeedNavCtrl.tabBarItem               = [[UITabBarItem alloc] initWithTitle:@"Home Feed"
                                                                           image:[UIImage imageNamed:@"home"]
                                                                             tag:0];
  
  // UINavigationController does not forward on preferredStatusBarStyle calls to its child view controllers.
  // Instead it manages its own state...
  //http://stackoverflow.com/questions/19022210/preferredstatusbarstyle-isnt-called/19513714#19513714
  homeFeedNavCtrl.navigationBar.barStyle = UIBarStyleBlack;


  // create Profile viewController & navController
//  UserProfileViewController *myProfileVC   = [[UserProfileViewController alloc] initWithMe];
  UIViewController *VC                         = [[UIViewController alloc] init];
  VC.view.backgroundColor                      = [UIColor purpleColor];
  
  UINavigationController *profileNavController = [[UINavigationController alloc] initWithRootViewController:VC];
  profileNavController.tabBarItem              = [[UITabBarItem alloc] initWithTitle:@"Profile"
                                                                               image:[UIImage imageNamed:@"profile"]
                                                                                 tag:0];

//  // create Photo Upload viewController & navController
//  UIViewController *VC1                      = [[UIViewController alloc] init];
//  VC1.view.backgroundColor                   = [UIColor redColor];
//  
//  UINavigationController *photoUploadNavCtrl = [[UINavigationController alloc] initWithRootViewController:VC1];
//  photoUploadNavCtrl.tabBarItem              = [[UITabBarItem alloc] initWithTitle:@"Upload"
//                                                                             image:[UIImage imageNamed:@"camera"]
//                                                                               tag:0];

  // create Photos Near Me viewController & navController
  PhotoMapViewController *photoNearMeVC      = [[PhotoMapViewController alloc] init];
  
  UINavigationController *photoNearMeNavCtrl = [[UINavigationController alloc] initWithRootViewController:photoNearMeVC];
  photoNearMeNavCtrl.tabBarItem              = [[UITabBarItem alloc] initWithTitle:@"Near Me"
                                                                             image:[UIImage imageNamed:@"earth"]
                                                                               tag:0];
  
  // configure UITabBarController and add viewControllers
  tabBarController.viewControllers        = @[homeFeedNavCtrl, photoNearMeNavCtrl, profileNavController];
  tabBarController.selectedViewController = homeFeedNavCtrl;
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  
  [self saveData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  
//  [_viewController refreshFeed]; 
//  NSLog(@"applicationWillEnterForeground - refreshing feed");
  [self getData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  [self getData];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  
  [self saveData];
}

#pragma mark - HelperMethods

-(void)saveData
{
}

-(void)getData
{
}

@end
