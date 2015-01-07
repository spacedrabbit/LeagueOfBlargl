//
//  AppDelegate.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/21/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchRiotTVController.h"

@interface AppDelegate ()

@property (strong, nonatomic) UIColor * riotBlue;
@property (strong, nonatomic) UIColor * riotYellow;
@property (strong, nonatomic) UIColor * riotOrange;

// -- blue color scale -- //
@property (strong, nonatomic) UIColor * riotDeepBlue;
@property (strong, nonatomic) UIColor * riotMediumWellBlue;
@property (strong, nonatomic) UIColor * riotMediumBlue;
@property (strong, nonatomic) UIColor * riotMediumRareBlue;
@property (strong, nonatomic) UIColor * riotRareBlue;

@property (strong, nonatomic) UIFont  * riotiOSFont;
@property (strong, nonatomic) NSShadow * riotiOSFontShadow;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //119	149	168
    self.riotBlue = [UIColor colorWithRed:0.059 green:0.343 blue:0.874 alpha:.7000];
    self.riotYellow = [UIColor colorWithRed:1.000 green:0.937 blue:0.046 alpha:1.000];
    self.riotOrange = [UIColor colorWithRed:1.000 green:0.613 blue:0.046 alpha:1.000];
    
    self.riotDeepBlue = [UIColor colorWithRed:0.076 green:0.141 blue:0.253 alpha:1.000];
    self.riotMediumWellBlue = [UIColor colorWithRed:0.167 green:0.289 blue:0.430 alpha:1.000];
    self.riotMediumBlue = [UIColor colorWithRed:0.610 green:0.735 blue:0.854 alpha:1.000];
    self.riotMediumRareBlue = [UIColor colorWithRed:0.721 green:0.800 blue:0.911 alpha:1.000];
    self.riotRareBlue = [UIColor colorWithRed:0.855 green:0.875 blue:0.975 alpha:1.000];
    
    self.riotiOSFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    self.riotiOSFontShadow = [[NSShadow alloc] init];
    [self.riotiOSFontShadow setShadowColor:self.riotDeepBlue];
    [self.riotiOSFontShadow setShadowOffset:CGSizeMake(1, 1)];
    [self.riotiOSFontShadow setShadowBlurRadius:10.0];
    
    SearchRiotTVController * rootViewController = [[SearchRiotTVController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController: rootViewController];
    
    
    
    [[UINavigationBar appearance] setBarTintColor:self.riotRareBlue];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                            NSFontAttributeName : self.riotiOSFont,
                                                            NSForegroundColorAttributeName : [UIColor whiteColor] ,
                                                            NSShadowAttributeName : self.riotiOSFontShadow
                                                           }];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UINavigationBar appearance] setTintColor:self.riotMediumRareBlue];
    
    
//    NSURLCache * URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
//    [NSURLCache setSharedURLCache:URLCache];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
    
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

@end
