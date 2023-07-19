//
//  NSObject+Properties.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Properties)

/// 获取类的所有属性
+ (NSArray *)getAllProperties;

@end

NS_ASSUME_NONNULL_END
