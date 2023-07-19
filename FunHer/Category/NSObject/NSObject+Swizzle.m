//
//  NSObject+Swizzle.m
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import "NSObject+Swizzle.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzle)

#pragma mark -- 实例方法交换
+ (void)swizzleOriginalSelector:(SEL)original withOptimizeSelector:(SEL)optimize {
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, original);
    Method optimizeMethod = class_getInstanceMethod(class, optimize);
    
    BOOL didAddMethod = class_addMethod(class,
                                        original,
                                         method_getImplementation(optimizeMethod),
                                         method_getTypeEncoding(optimizeMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            optimize,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        method_exchangeImplementations(originalMethod, optimizeMethod);
    }
}

#pragma mark -- 类方法交换
+ (void)swizzleClassOriginalSelector:(SEL)original withOptimizeSelector:(SEL)optimize {
    Class class = [self class];
    
    Method originalMethod = class_getClassMethod(class, original);
    Method optimizeMethod = class_getClassMethod(class, optimize);
    
    Class mateClass = objc_getMetaClass(NSStringFromClass(class).UTF8String);
    
    BOOL didAddMethod = class_addMethod(mateClass,
                                        original,
                                         method_getImplementation(optimizeMethod),
                                         method_getTypeEncoding(optimizeMethod));
    
    if (didAddMethod) {
        class_replaceMethod(mateClass,
                            optimize,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        method_exchangeImplementations(originalMethod, optimizeMethod);
    }
}

@end
