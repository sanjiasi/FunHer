//
//  UIViewController+Alert.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Alert)

/// 只有确定按钮
- (void)takeAlert:(NSString * _Nullable)title withMessage:(NSString * _Nullable)message actionHandler:(void(^ __nullable)(void))actionHandler;

/// 有取消和确定按钮
- (void)takeAlertWithTitle:(NSString * _Nullable)title message:(NSString * _Nullable)msg  actionBlock:(void (^)(void))actionBlock cancelBlock:(void (^)(void))cancelBlock;

/// 带输入框且有取消和确定按钮
- (void)takeAlertWithTitle:(NSString * _Nullable)title placeHolder:(NSString * _Nullable)text  actionBlock:(void (^)(NSString *fieldText))actionBlock cancelBlock:(void (^)(void))cancelBlock;

@end

NS_ASSUME_NONNULL_END
