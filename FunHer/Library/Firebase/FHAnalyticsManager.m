//
//  FHAnalyticsManager.m
//  FunHer
//
//  Created by GLA on 2023/9/20.
//

#import "FHAnalyticsManager.h"
#import <FirebaseAnalytics/FirebaseAnalytics.h>

@implementation FHAnalyticsManager

+ (void)logEventWithName:(NSString *)name {
    [FIRAnalytics logEventWithName:name parameters:nil];
}

+ (void)logEvent:(NSString *)name parameters:(NSDictionary *)params {
    if (params.allValues.count > 0) {
        NSString *jsonStr = @"";
        for (NSString *str in [params allValues]) {
            jsonStr = [NSString stringWithFormat:@"%@_%@",jsonStr,str];
        }
        name = [NSString stringWithFormat:@"%@_%@",name, jsonStr];
    }
    if (name.length > 40) {
        name = [name substringToIndex:40];
    }
    [FIRAnalytics logEventWithName:name parameters:params];
}

@end
