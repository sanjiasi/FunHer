//
//  NSObject+Selector.m
//  FunHer
//
//  Created by GLA on 2023/8/7.
//

#import "NSObject+Selector.h"

@implementation NSObject (Selector)

- (void)invokeWithSelector:(NSString *)method {
    if (method) {
        SEL selector = NSSelectorFromString(method);
        if ([self respondsToSelector:selector]) {
            ((void(*)(id,SEL))[self methodForSelector:selector])(self,selector);
        }
    }
}

@end
