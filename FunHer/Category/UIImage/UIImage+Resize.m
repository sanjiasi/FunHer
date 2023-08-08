//
//  UIImage+Resize.m
//  FunHer
//
//  Created by GLA on 2023/8/8.
//

#import "UIImage+Resize.h"
#import <MobileCoreServices/MobileCoreServices.h>

CGFloat const FHImageMaxPiexl = 8000000.00;//最大8百万像素
CGFloat const FHThumbImageMaxPiexl = 160000.00;//缩率图的最大像素

@implementation UIImage (Resize)

#pragma mark -- 缩略图 -- 使用Image i/o 避免在改变图片大小的过程中产生临时的bitmap(栅格图)，就能够在很大程度上减少内存的占有
/*
 options中的
 kCGImageSourceCreateThumbnailWithTransform 自动将图像旋转到正确的方向
 kCGImageSourceThumbnailMaxPixelSize 指定缩略图的最大宽度和高度(以像素为单位)。如果此键未指定，缩略图的宽度和高度为不受限制，缩略图可能和图片本身一样大。如果指定，此键的值必须是CFNumberRef。* /
 kCGImageSourceCreateThumbnailFromImageAlways *如果图像源文件中存在缩略图。缩略图将由完整图像创建，受kCGImageSourceThumbnailMaxPixelSize——如果没有最大像素大小指定，则缩略图将为完整图像的大小，可能不是你想要的。这个键的值必须是
 CFBooleanRef;这个键的默认值是kCFBooleanFalse。
 */
+ (CGImageRef)scaleImageWithData:(NSData *)data withSize:(CGFloat)maxPixeSize {
    //读取图像源
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    NSDictionary *options = @{(__bridge id)kCGImageSourceCreateThumbnailWithTransform:(__bridge id)kCFBooleanTrue,
                              (__bridge id)kCGImageSourceCreateThumbnailFromImageAlways:(__bridge id)kCFBooleanTrue,
                              (__bridge id)kCGImageSourceThumbnailMaxPixelSize:[NSNumber numberWithFloat:maxPixeSize]};
    //创建缩略图，根据字典
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
    
    if (sourceRef) {
        CFRelease(sourceRef);
    }
    return imageRef;
}

+ (BOOL)resizeOriginalImage:(NSData *)data imageSize:(CGSize)size saveAtPath:(NSString *)path {
    if ((size.width * size.height) > FHImageMaxPiexl) {
        CGFloat settingSize = [self getImageSettingSize:size byMaxSize:FHImageMaxPiexl];
        CGImageRef imageRef = [self scaleImageWithData:data withSize:settingSize];
        BOOL ok = CGImageWriteToFile(imageRef, path);
        return ok;
    } else {
        return [data writeToFile:path atomically:YES];
    }
}

+ (BOOL)resizeThumbImage:(NSData *)data imageSize:(CGSize)size saveAtPath:(NSString *)path {
    if ((size.width * size.height) > FHThumbImageMaxPiexl) {
        CGFloat settingSize = [self getImageSettingSize:size byMaxSize:FHThumbImageMaxPiexl];
        CGImageRef imageRef = [self scaleImageWithData:data withSize:settingSize];
        BOOL ok = CGImageWriteToFile(imageRef, path);
        return ok;
    } else {
        return [data writeToFile:path atomically:YES];
    }
}

+ (CGFloat)getImageSettingSize:(CGSize)size byMaxSize:(CGFloat)maxPiexl {
    CGFloat fixelW = size.width;
    CGFloat fixelH = size.height;
    CGFloat maxPixeSize = MAX(fixelW, fixelH);
    CGFloat imagePiexl = fixelW * fixelH;
    if (imagePiexl > maxPiexl) {//计算图片压缩后的尺寸
        float rate = imagePiexl / maxPiexl;
        float scale = sqrtf(rate);
        CGFloat settingSize = maxPixeSize / scale;
        return settingSize;
    }
    return maxPixeSize;
}

BOOL CGImageWriteToFile(CGImageRef image, NSString *path) {
    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    CGImageRelease(image);
    BOOL isSucceed = YES;
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
        isSucceed = NO;
    }
    CFRelease(destination);
    return isSucceed;
}

@end
