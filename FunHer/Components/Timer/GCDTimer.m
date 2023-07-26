//
//  GCDTimer.m
//  FunHer
//
//  Created by GLA on 2023/7/26.
//

#import "GCDTimer.h"

/**
 创建重复定时器
 
 @param timeInterval 时间间隔,单位: s ( <= 0时,则置为1)
 @param handler 定时器触发回调
 @return 定时器
 */
GCDTimer CreateGCDRepeatTimer(NSTimeInterval timeInterval, dispatch_block_t handler) {
    // 创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 1. 创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 2. 设置时间
    /**
     * 计时的时间间隔(如果 <= 0, 则置为1)
     */
    uint64_t time_interval_ms = timeInterval <= 0 ? 1000 : (timeInterval * 1000);
    /**
     * 开始时间
     * 第一个参数 when: 一般是DISPATCH_TIME_NOW，表示从现在开始
     * 第二个参数 delta: 延时时间,这里要特别注意的是delta参数是"纳秒"!
     */
    dispatch_time_t start_time = dispatch_time(DISPATCH_TIME_NOW, time_interval_ms * NSEC_PER_MSEC);
    /**
     * 第一个参数: 被设置的定时器
     * 第二个参数: 开始时间
     * 第三个参数: 时间间隔,注意是"纳秒"!
     * 第四个参数: 误差,置0就好
     */
    dispatch_source_set_timer(timer, start_time, time_interval_ms * NSEC_PER_MSEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        // 执行回调
        if (handler) {
            handler();
        }
    });
    // 3. 启动定时器
    dispatch_resume(timer);
    return timer;
}

/**
 停止定时器
 
 @param timer 定时器
 */
void CancelGCDRepeatTimer(GCDTimer timer) {
    if (timer) {
        dispatch_source_cancel(timer);
        timer = nil;
    }
}


/**
 创建倒计时定时器

 @param time 倒计时时长,单位: s ( <= 0时,则置为1)
 @param handler 定时器触发回调
 @return 定时器
 */
GCDTimer CreateGCDCountdownTimer(NSTimeInterval time, dispatch_block_t handler) {
    // 创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 1. 创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 2. 设置时间
    /**
     * 计时的时间间隔(如果 <= 0, 则置为1)
     */
    uint64_t time_interval_ms = time <= 0 ? 1000 : (time * 1000);
    /**
     * 开始时间
     * 第一个参数 when: 一般是DISPATCH_TIME_NOW，表示从现在开始
     * 第二个参数 delta: 延时时间,这里要特别注意的是delta参数是"纳秒"!
     */
    dispatch_time_t start_time = dispatch_time(DISPATCH_TIME_NOW, time_interval_ms * NSEC_PER_MSEC);
    /**
     * 第一个参数: 被设置的定时器
     * 第二个参数: 开始时间
     * 第三个参数: 时间间隔,注意是"纳秒"!
     * 第四个参数: 误差,置0就好
     */
    dispatch_source_set_timer(timer, start_time, time_interval_ms * NSEC_PER_MSEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        // 停止定时器
        dispatch_source_cancel(timer);
        
        // 执行回调
        if (handler) {
            handler();
        }
    });
    // 3. 启动定时器
    dispatch_resume(timer);
    return timer;
}

/**
 停止定时器
 
 @param timer 定时器
 */
void CancelGCDCountdownTimer(GCDTimer timer) {
    if (timer) {
        dispatch_source_cancel(timer);
        timer = nil;
    }
}
