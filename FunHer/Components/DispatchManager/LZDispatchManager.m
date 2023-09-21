//
//  LZDispatchManager.m
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import "LZDispatchManager.h"

@implementation LZDispatchManager

+ (void)mainQueueHandler:(HandlerTask)task {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, task);
}

+ (void)globalQueueHandler:(HandlerTask)task {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, task);
}

+ (void)globalQueueHandler:(HandlerTask)task withMainCompleted:(HandlerTask)completed {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if (task) {
            task();
            [self mainQueueHandler:completed];
        }
    });
}

+ (void)asyncConcurrentByGroup:(nonnull dispatch_group_t)group_t withHandler:(nonnull HandlerTask)task {
    dispatch_queue_t queue = [self getQueueForConcurrent];
    dispatch_group_async(group_t, queue, task);
}

+ (void)groupTask:(dispatch_group_t)group_t withCompleted:(HandlerTask)task {
    dispatch_group_notify(group_t, dispatch_get_main_queue(), task);
}

+ (void)afterTime:(NSTimeInterval)time withMainQueueHandler:(HandlerTask)task {
    dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_after(time_t, queue, task);
}

+ (dispatch_queue_t)getSerialQueue {
    dispatch_queue_t serialQueue = dispatch_queue_create("lz_serial", DISPATCH_QUEUE_SERIAL);
    return serialQueue;
}

+ (dispatch_queue_t)getConcurrentQueue {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("lz_concurrent", DISPATCH_QUEUE_CONCURRENT);
    return concurrentQueue;
}

#pragma mark -- 用于并发的队列
+ (dispatch_queue_t)getQueueForConcurrent {//从队列池中获取空闲的串行队列
    dispatch_queue_t queue = YYDispatchQueueGetForQOS(NSQualityOfServiceUserInitiated);
    return queue;
}

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation {
    UIImage * newImg = [UIImage new];
    UIImageOrientation imgOrientation = image.imageOrientation;
    UIImageOrientation changeOr = UIImageOrientationRight;
    if (orientation == UIImageOrientationRight) {
        switch (imgOrientation) {
            case UIImageOrientationUp:
                changeOr = UIImageOrientationRight;
                break;
            case UIImageOrientationDown:
                changeOr = UIImageOrientationLeft;
                break;
            case UIImageOrientationLeft:
                changeOr = UIImageOrientationUp;
                break;
            case UIImageOrientationRight:
                changeOr = UIImageOrientationDown;
                break;
            default:
                break;
        }
    }
    
    if (orientation == UIImageOrientationLeft) {
        switch (imgOrientation) {
            case UIImageOrientationUp:
                changeOr = UIImageOrientationLeft;
                break;
            case UIImageOrientationDown:
                changeOr = UIImageOrientationRight;
                break;
            case UIImageOrientationLeft:
                changeOr = UIImageOrientationDown;
                break;
            case UIImageOrientationRight:
                changeOr = UIImageOrientationUp;
                break;
            default:
                break;
        }
    }
    newImg = [UIImage imageWithCGImage:[image CGImage] scale:[image scale] orientation: changeOr];//这里只是改变了图片的imageOrientation属性 imageview加载图片时会根据图片的imageOrientation对图片进行旋转
    return newImg;
}

@end
