//
//  FHRootVCCommand.m
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import "FHRootVCCommand.h"
#import "FHFileListVC.h"

@implementation FHRootVCCommand

- (void)execute {
    FHFileListVC *vc = [[FHFileListVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    KAppDelegate.window.rootViewController = nav;
}

@end
