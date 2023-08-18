//
//  AppDelegate.m
//  FunHer
//
//  Created by GLA on 2023/7/18.
//

#import "AppDelegate.h"
#import "FHServiceComandsManager.h"
#import "FHFileListVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = UIColor.whiteColor;
    [[FHServiceComandsManager configurations] enumerateObjectsUsingBlock:^(id<FHServiceCommand>  _Nonnull commad, NSUInteger idx, BOOL * _Nonnull stop) {
        [commad execute];
    }];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
