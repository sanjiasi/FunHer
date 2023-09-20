//
//  FHAnalyticsManager.h
//  FunHer
//
//  Created by GLA on 2023/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHAnalyticsManager : NSObject

/// 事件埋点
/// @param name  方法名
+ (void)logEventWithName:(NSString *)name;

+ (void)logEvent:(NSString *)name parameters:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
