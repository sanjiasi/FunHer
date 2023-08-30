//
//  UIImage+Filter.h
//  FunHer
//
//  Created by GLA on 2023/8/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Filter)

/// 灰度图
/// - Parameter image: 原图
+ (UIImage *)filterByGrayscaleImage:(UIImage *)image;

/// 怀旧
/// - Parameter image: 原图
+ (UIImage *)filterByNostalgicImage:(UIImage *)image;

/// 彩色
/// - Parameter image: 原图
+ (UIImage *)filterByMagicColorImage:(UIImage *)image;

///  黑白
/// - Parameter image: 原图
+ (UIImage *)filterByBWImage:(UIImage *)image;

///  去阴影
/// - Parameter image: 原图
+ (UIImage *)filterByNoShadowImage:(UIImage *)image;

/// -- 清理GPU缓存
+ (void)clearGPUCache;

@end

NS_ASSUME_NONNULL_END
