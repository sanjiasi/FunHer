//
//  UIViewController+Alert.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Alert)

/// 只有确定按钮
- (void)takeAlert:(NSString * _Nullable)title withMessage:(NSString * _Nullable)message actionHandler:(void(^ __nullable)(void))actionHandler;

/// 有取消和确定按钮
- (void)takeAlertWithTitle:(NSString * _Nullable)title message:(NSString * _Nullable)msg  actionBlock:(void (^)(void))actionBlock cancleBlock:(void (^)(void))cancleBlock;

@end

NS_ASSUME_NONNULL_END
