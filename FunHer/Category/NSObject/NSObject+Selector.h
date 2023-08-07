//
//  NSObject+Selector.h
//  FunHer
//
//  Created by GLA on 2023/8/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Selector)

- (void)invokeWithSelector:(NSString *)method;

@end

NS_ASSUME_NONNULL_END
