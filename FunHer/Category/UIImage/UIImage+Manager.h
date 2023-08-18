//
//  UIImage+Manager.h
//  FunHer
//
//  Created by GLA on 2023/8/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Manager)

///  -- 保存图片到指定目录下
+ (BOOL)saveImage:(UIImage *)photoImage atPath:(NSString *)path;

+ (NSData *)saveImageForData:(UIImage *)photoImage;

@end

NS_ASSUME_NONNULL_END
