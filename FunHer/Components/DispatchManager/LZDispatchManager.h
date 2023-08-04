//
//  LZDispatchManager.h
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import <Foundation/Foundation.h>

typedef void (^HandlerTask)(void);

NS_ASSUME_NONNULL_BEGIN

@interface LZDispatchManager : NSObject

/// 主线程 处理任务
/// - Parameter task: 任务
+ (void)mainQueueHandler:(HandlerTask)task;

/// 全局队列 处理任务
/// - Parameter task: 任务
+ (void)globalQueueHandler:(HandlerTask)task;

/// 全局队列 处理任务 完成后返回主线程处理
/// - Parameter task: 任务
+ (void)globalQueueHandler:(HandlerTask)task withMainCompleted:(HandlerTask)completed;

/// 异步并发处理任务
/// - Parameter task:任务
+ (void)asyncConcurrentByGroup:(dispatch_group_t)group_t withHandler:(HandlerTask)task;

/// 延迟处理任务
///   - time: 延迟时间
///   - task: 任务
+ (void)afterTime:(NSTimeInterval)time withMainQueueHandler:(HandlerTask)task;

/// 任务组完成
/// - Parameter task: 回调处理
+ (void)groupTask:(dispatch_group_t)group_t withCompleted:(HandlerTask)task;

/// 串行队列
+ (dispatch_queue_t)getSerialQueue;

/// 并发队列
+ (dispatch_queue_t)getConcurrentQueue;

/// -- 用于并发的队列
+ (dispatch_queue_t)getQueueForConcurrent;

@end

NS_ASSUME_NONNULL_END
