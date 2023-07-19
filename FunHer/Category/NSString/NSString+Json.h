//
//  NSString+Json.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Json)

/// 字符串转字典
- (NSDictionary *)toDictionary;

/// 字符串转数组
- (NSArray *)toArray;

@end

NS_ASSUME_NONNULL_END
