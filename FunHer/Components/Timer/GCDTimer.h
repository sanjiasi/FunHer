//
//  GCDTimer.h
//  FunHer
//
//  Created by GLA on 2023/7/26.
//

#import <Foundation/Foundation.h>

/**
 * 定时器类型
 */
typedef dispatch_source_t GCDTimer;

/**
 创建重复定时器
 
 @param timeInterval 时间间隔,单位: s ( <= 0时,则置为1)
 @param handler 定时器触发回调
 @return 定时器
 */
GCDTimer CreateGCDRepeatTimer(NSTimeInterval timeInterval, dispatch_block_t handler);

/**
 停止定时器
 
 @param timer 定时器
 */
void CancelGCDRepeatTimer(GCDTimer timer);


/**
 创建倒计时定时器
 
 @param time 倒计时时长,单位: s ( <= 0时,则置为1)
 @param handler 定时器触发回调
 @return 定时器
 */
GCDTimer CreateGCDCountdownTimer(NSTimeInterval time, dispatch_block_t handler);

/**
 停止定时器
 
 @param timer 定时器
 */
void CancelGCDCountdownTimer(GCDTimer timer);
