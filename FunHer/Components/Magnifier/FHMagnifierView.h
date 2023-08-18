//
//  FHMagnifierView.h
//  FunHer
//
//  Created by GLA on 2023/8/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMagnifierView : UIView
/// 放大框
@property(nonatomic,strong)UIView * magnifyView;

/// 触摸点
@property(nonatomic)CGPoint pointTomagnify;

/// 聚焦点
@property (nonatomic, strong) CAShapeLayer *_Nullable aimLine;

/// 聚焦点颜色
@property (nonatomic, strong) UIColor *aimColor;

/// 聚焦点大小
@property (nonatomic, assign) CGFloat aimSize;

@end

NS_ASSUME_NONNULL_END
