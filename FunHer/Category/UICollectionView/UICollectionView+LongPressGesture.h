//
//  UICollectionView+LongPressGesture.h
//  FunHer
//
//  Created by GLA on 2023/9/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (LongPressGesture)

/// -- 添加长按手势
- (void)addLongPressGestureWithDidSelected:(void(^)(NSIndexPath *indexPath))selectedBlock;

@end

NS_ASSUME_NONNULL_END
