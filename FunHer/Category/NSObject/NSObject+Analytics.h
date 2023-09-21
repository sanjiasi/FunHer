//
//  NSObject+Analytics.h
//  FunHer
//
//  Created by GLA on 2023/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Analytics)

/// 收集错误
/// - Parameter name: 方法名
- (void)getErrorWithName:(NSString *)name;

/// 收集问题分析1
/// - Parameter name: 方法名
- (void)getEventWithName:(NSString *)name;

/// 收集问题分析2
///   - name: 方法名
///   - params: 参数
- (void)getEvent:(NSString *)name parameters:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
