//
//  UICollectionView+LongPressGesture.m
//  FunHer
//
//  Created by GLA on 2023/9/7.
//

#import "UICollectionView+LongPressGesture.h"
#import "FHSystemActionManager.h"
#import <objc/runtime.h>

static void *SelectedBlockKey = &SelectedBlockKey;

typedef void(^DidSelectedBlock)(NSIndexPath *aIndex);

@interface UICollectionView ()
@property (nonatomic, copy) DidSelectedBlock didSelectedBlock;

@end

@implementation UICollectionView (LongPressGesture)

- (void)addLongPressGestureWithDidSelected:(void (^)(NSIndexPath * _Nonnull))selectedBlock {
    self.didSelectedBlock = selectedBlock;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognizer:)];
    [self addGestureRecognizer:longPress];
}

#pragma mark -- 长按手势识别
- (void)longGestureRecognizer:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            //震动反馈
            [FHSystemActionManager impactFeedback];
            //手势开始
            //判断手势落点位置是否在row上
            NSIndexPath *indexPath = [self indexPathForItemAtPoint:[longPress locationInView:self]];
            if (indexPath == nil) break;
            if (self.didSelectedBlock) {
                self.didSelectedBlock(indexPath);
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            //iOS9 方法 移动过程中随时更新cell位置
        }
            break;
        case UIGestureRecognizerStateEnded: {
            //手势结束
        }
            break;
        default:
            break;
    }
}

#pragma mark -- 添加属性 DidSelectedBlock  增加get、set方法
- (void)setDidSelectedBlock:(DidSelectedBlock)didSelectedBlock {
    objc_setAssociatedObject(self, &SelectedBlockKey, didSelectedBlock, OBJC_ASSOCIATION_COPY);
}

- (DidSelectedBlock)didSelectedBlock {
    id block = objc_getAssociatedObject(self, &SelectedBlockKey);
    return block;
}

@end
