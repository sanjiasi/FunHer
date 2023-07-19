//
//  NSArray+Json.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Json)

/// 转json字符串
- (NSString *)toJsonStr;

@end

NS_ASSUME_NONNULL_END
