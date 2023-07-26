//
//  FHToast.h
//  FunHer
//
//  Created by GLA on 2023/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHToast : NSObject

//创建声明单例方法
+ (instancetype)shareInstance;

//提示信息并在几秒后消失 统一toast显示时间
- (void)makeToast:(NSString *)message;

//提示信息并在几秒后消失
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration;

//立即消失
- (void)hiddenToast;

//加载动画
- (void)makeLoading;

//动画消失
- (void)hiddenLoadingView;

- (void)setToastCenter:(CGPoint)center;

@end

NS_ASSUME_NONNULL_END
