//
//  FHNotificationManager.h
//  FunHer
//
//  Created by GLA on 2023/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const FHAddImageByDocNotification; ///在文档中添加新图片

@interface FHNotificationManager : NSObject

/// 注册通知监听
/// @param observer  通知监听者
/// @param selector  响应方法
+ (void)addNotiOberver:(id)observer forName:(NSString *)name selector:(SEL)selector;

/// 推送通知信息
/// @param obj 推送者
/// @param info 附带信息
+ (void)pushNotificationName:(NSString *)name withObject:(nullable id)obj info:(nullable NSDictionary *)info;

/// 移除通知监听
/// @param observer 通知监听者
+ (void)removeNotiOberver:(id)observer forName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
