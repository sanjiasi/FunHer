//
//  NSObject+Analytics.m
//  FunHer
//
//  Created by GLA on 2023/7/26.
//

#import "NSObject+Analytics.h"
#import "FHAnalyticsManager.h"

@implementation NSObject (Analytics)

#pragma mark -- 收集错误
- (void)getErrorWithName:(NSString *)name {
    [self eventNameWithFunc:name];
    NSString *func = [self eventNameWithFunc:name];
    if (DEBUG) {
        DELog(@"event = %@",func);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[FHToast shareInstance] makeToast:func];
        });
    }
}

#pragma mark -- 收集问题分析
- (void)getEventWithName:(NSString *)name {
    NSString *func = [self eventNameWithFunc:name];
    [FHAnalyticsManager logEventWithName:func];
}

- (void)getEvent:(NSString *)name parameters:(NSDictionary *)params {
    NSString *func = [self eventNameWithFunc:name];
    [FHAnalyticsManager logEvent:func parameters:params];
}


- (NSString *)eventNameWithFunc:(NSString *)func   {
    NSString *selfClass = NSStringFromClass([self class]);
    NSString *name = [NSString stringWithFormat:@"%@_%@", selfClass, func];
    return name;
}

@end
