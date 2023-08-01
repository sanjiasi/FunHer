//
//  SSPopListView.h
//  SimpleScan
//
//  Created by GLA on 2022/6/30.
//  Copyright © 2022 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSPopListView : UIView
@property (copy, nonatomic) void(^cancelBlock)(void);
/**
 ActionSheet 自定义
 @param selectBlock 选择回调
 */
- (instancetype)initWithItems:(NSArray *)items selectedBlock:(void(^)(NSInteger index))selectBlock;

/// 展示弹窗
- (void)showActionView;

/// 隐藏弹窗
- (void)dismissActionView;

@end

NS_ASSUME_NONNULL_END
