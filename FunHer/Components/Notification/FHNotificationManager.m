//
//  FHNotificationManager.m
//  FunHer
//
//  Created by GLA on 2023/8/31.
//

#import "FHNotificationManager.h"

#pragma mark -- NSNotification
NSString * const FHCreateDocNotification            = @"FHCreateDocNotificationKey";//创建新文档

@implementation FHNotificationManager

+ (void)addNotiOberver:(id)observer forName:(NSString *)name selector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:nil];
}

+ (void)pushNotificationName:(NSString *)name withObject:(id)obj info:(NSDictionary *)info {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj userInfo:info];
}

+ (void)removeNotiOberver:(id)observer forName:(NSString *)name {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:nil];
}

@end
