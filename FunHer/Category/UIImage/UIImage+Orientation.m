//
//  UIImage+Orientation.m
//  FunHer
//
//  Created by GLA on 2023/8/25.
//

#import "UIImage+Orientation.h"

@implementation UIImage (Orientation)

#pragma mark -- 旋转图片
+ (UIImage *)changeRotate:(UIImageOrientation)orientation withImage:(UIImage *)image {
    UIImageOrientation imgOrientation = image.imageOrientation;
    UIImageOrientation changeOr = UIImageOrientationRight;
    if (orientation == UIImageOrientationRight) {
        switch (imgOrientation) {
            case UIImageOrientationUp:
                changeOr = UIImageOrientationRight;
                break;
            case UIImageOrientationDown:
                changeOr = UIImageOrientationLeft;
                break;
            case UIImageOrientationLeft:
                changeOr = UIImageOrientationUp;
                break;
            case UIImageOrientationRight:
                changeOr = UIImageOrientationDown;
                break;
            default:
                break;
        }
    }
    
    if (orientation == UIImageOrientationLeft) {
        switch (imgOrientation) {
            case UIImageOrientationUp:
                changeOr = UIImageOrientationLeft;
                break;
            case UIImageOrientationDown:
                changeOr = UIImageOrientationRight;
                break;
            case UIImageOrientationLeft:
                changeOr = UIImageOrientationDown;
                break;
            case UIImageOrientationRight:
                changeOr = UIImageOrientationUp;
                break;
            default:
                break;
        }
    }
    
    UIImage *newImg = [UIImage imageWithCGImage:[image CGImage] scale:[image scale] orientation: changeOr];//这里只是改变了图片的imageOrientation属性 imageview加载图片时会根据图片的imageOrientation对图片进行旋转
    return newImg;
}

- (UIImage *)changeRotate:(UIImageOrientation)orientation {
    UIImage *image = (UIImage *)self;
    UIImageOrientation imgOrientation = image.imageOrientation;
    UIImageOrientation changeOr = UIImageOrientationRight;
    if (orientation == UIImageOrientationRight) {
        switch (imgOrientation) {
            case UIImageOrientationUp:
                changeOr = UIImageOrientationRight;
                break;
            case UIImageOrientationDown:
                changeOr = UIImageOrientationLeft;
                break;
            case UIImageOrientationLeft:
                changeOr = UIImageOrientationUp;
                break;
            case UIImageOrientationRight:
                changeOr = UIImageOrientationDown;
                break;
            default:
                break;
        }
    }
    
    if (orientation == UIImageOrientationLeft) {
        switch (imgOrientation) {
            case UIImageOrientationUp:
                changeOr = UIImageOrientationLeft;
                break;
            case UIImageOrientationDown:
                changeOr = UIImageOrientationRight;
                break;
            case UIImageOrientationLeft:
                changeOr = UIImageOrientationDown;
                break;
            case UIImageOrientationRight:
                changeOr = UIImageOrientationUp;
                break;
            default:
                break;
        }
    }
    
    UIImage *newImg = [UIImage imageWithCGImage:[image CGImage] scale:[image scale] orientation: changeOr];//这里只是改变了图片的imageOrientation属性 imageview加载图片时会根据图片的imageOrientation对图片进行旋转
    return newImg;
}

#pragma mark -- 修正图片朝向
- (UIImage *)fixUpOrientation {
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
 
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
 
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
 
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
 
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
 
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
 
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
 
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
 
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
 
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
