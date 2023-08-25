//
//  UIImage+Orientation.h
//  FunHer
//
//  Created by GLA on 2023/8/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Orientation)

/// -- 旋转图片
/// - Parameter orientation: 旋转方向(向左转，向右转)
- (UIImage *)rotate:(UIImageOrientation)orientation;

/// 修正图片朝向
- (UIImage *)fixUpOrientation;

@end

NS_ASSUME_NONNULL_END
