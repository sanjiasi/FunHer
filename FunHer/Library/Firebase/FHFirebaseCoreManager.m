//
//  FHFirebaseCoreManager.m
//  FunHer
//
//  Created by GLA on 2023/9/20.
//

#import "FHFirebaseCoreManager.h"
#import <FirebaseCore/FirebaseCore.h>

@implementation FHFirebaseCoreManager

#pragma mark -- firebase初始化 必须放在最前面
+ (void)configure {
    [FIRApp configure];
}

@end
