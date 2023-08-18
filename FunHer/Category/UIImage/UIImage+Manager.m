//
//  UIImage+Manager.m
//  FunHer
//
//  Created by GLA on 2023/8/18.
//

#import "UIImage+Manager.h"

/// 保存JPG图片的比例
CGFloat const PicScale = 0.6;

@implementation UIImage (Manager)

#pragma mark  -- 保存图片到指定目录下
+ (BOOL)saveImage:(UIImage *)photoImage atPath:(NSString *)path {
    NSData *imgData = [self saveImageForData:photoImage];
    BOOL result = [imgData writeToFile:path atomically:YES];
    return result;
}

+ (NSData *)saveImageForData:(UIImage *)photoImage {
    NSData *data = UIImageJPEGRepresentation(photoImage, PicScale);
    return data;
}

@end
