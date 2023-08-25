//
//  UIImage+Resize.h
//  FunHer
//
//  Created by GLA on 2023/8/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Resize)

/// 压缩图片
/// - Parameters:
///   - data: 图片资源
///   - size: 图片像素
+ (UIImage *)shrinkImageWithData:(NSData *)data withSize:(CGSize)size;

/// 压缩图片并保存
+ (BOOL)shrinkImage:(NSData *)data imageSize:(CGSize)size saveAtPath:(NSString *)path;

/// 压缩原图
///   - data: 图片资源
///   - size: 图片像素
///   - path: 保存路径
+ (BOOL)resizeOriginalImage:(NSData *)data imageSize:(CGSize)size saveAtPath:(NSString *)path;

/// 压缩封面图
///   - data: 图片资源
///   - size: 图片像素
///   - path: 保存路径
+ (BOOL)resizeThumbImage:(NSData *)data imageSize:(CGSize)size saveAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
