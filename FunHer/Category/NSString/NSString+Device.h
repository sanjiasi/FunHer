//
//  NSString+Device.h
//  FunHer
//
//  Created by GLA on 2023/9/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Device)

/// 设备版本/型号
+ (NSString *)deviceVersion;

/// 系统版本
+ (NSString *)systemVersion;

/// app 版本号
+ (NSString *)appVersion;

/// app 名称
+ (NSString *)appName;

/// app id
+ (NSString *)appBundleId;

@end

NS_ASSUME_NONNULL_END
