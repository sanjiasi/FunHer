//
//  NSObject+Swizzle.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Swizzle)

/// -- 实例方法交换
+ (void)swizzleOriginalSelector:(SEL)original withOptimizeSelector:(SEL)optimize;

/// -- 类方法交换
+ (void)swizzleClassOriginalSelector:(SEL)original withOptimizeSelector:(SEL)optimize;

@end

NS_ASSUME_NONNULL_END
