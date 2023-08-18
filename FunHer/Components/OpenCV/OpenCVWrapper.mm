//
//  OpenCVWrapper.m
//  CamScanner
//
//  Created by Srinija on 16/05/17.
//  Copyright © 2017 Srinija Ammapalli. All rights reserved.
//

#undef NO

//#if __has_include(<opencv2/imgcodecs/ios.h>)

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/highgui.hpp>

//#include <iostream>
//#import <opencv2/core.hpp>
//#import <opencv2/imgproc.hpp>
//#import<opencv2/stitching.hpp>


#import "OpenCVWrapper.h"
#import <GPUImage/GPUImage.h>

using namespace std;
using namespace cv;

@implementation OpenCVWrapper



+(NSMutableArray *) getLargestSquarePoints: (UIImage *) image : (CGSize) size :(BOOL)isAutomatic{
    if (!image.size.width) {//出现用户传入的图片为空的情况--目前没有复现，先做判空处理
        return nil;
    }
    if (!size.width) {
        return nil;
    }
    cv::Mat imageMat;
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);

    imageMat = cvMat;

    cv::resize(imageMat, imageMat, cvSize(size.width, size.height));
    
    std::vector<std::vector<cv::Point> >rectangle;
    std::vector<cv::Point> largestRectangle;
    
    getRectangles(imageMat, rectangle);
    getlargestRectangle(rectangle, largestRectangle);
    //识别功能 现在先不要 屏蔽掉 后面用到再打开
    if (isAutomatic) {
        
        if (largestRectangle.size() == 4)
        {
            
            //        Thanks to: https://stackoverflow.com/questions/20395547/sorting-an-array-of-x-and-y-vertice-points-ios-objective-c/20399468#20399468
            
            NSMutableArray *points = @[].mutableCopy;
            for (int i = 0; i < largestRectangle.size(); i ++) {//坐标点校验 大于0 且不大于视图的宽度/高度
                CGFloat potx = fmax((CGFloat)largestRectangle[i].x, 0);
                potx = fminf(potx, size.width);
                
                CGFloat poty = fmax((CGFloat)largestRectangle[i].y, 0);
                poty = fminf(poty, size.height);
                
                [points addObject:[NSValue valueWithCGPoint:(CGPoint){potx, poty}]];
            }
            
            CGPoint min = [points[0] CGPointValue];
            CGPoint max = min;
            for (NSValue *value in points) {
                CGPoint point = [value CGPointValue];
                min.x = fminf(point.x, min.x);
                min.y = fminf(point.y, min.y);
                max.x = fmaxf(point.x, max.x);
                max.y = fmaxf(point.y, max.y);
            }
            
            CGPoint center = {
                0.5f * (min.x + max.x),
                0.5f * (min.y + max.y),
            };
            
            NSNumber *(^angleFromPoint)(id) = ^(NSValue *value){
                CGPoint point = [value CGPointValue];
                CGFloat theta = atan2f(point.y - center.y, point.x - center.x);
                CGFloat angle = fmodf(M_PI - M_PI_4 + theta, 2 * M_PI);
                return @(angle);
            };
            
            NSArray *sortedPoints = [points sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                return [angleFromPoint(a) compare:angleFromPoint(b)];
            }];
            
            NSMutableArray *squarePoints = [[NSMutableArray alloc] init];
            for (NSValue *value in sortedPoints) {
                [squarePoints addObject:value];
            }
            imageMat.release();
            
            return squarePoints;
        }
        else{
            imageMat.release();
            return nil;
        }
    }else{
        imageMat.release();
        return nil;
    }
    return nil;
}

// http://stackoverflow.com/questions/8667818/opencv-c-obj-c-detecting-a-sheet-of-paper-square-detection
void getRectangles(cv::Mat& image, std::vector<std::vector<cv::Point> >&rectangles) {
    
    // blur will enhance edge detection
    
    cv::Mat blurred(image);
    cv::cvtColor(blurred, blurred, cv::COLOR_BGR2GRAY);
    GaussianBlur(image, blurred, cvSize(11,11), 0);
//    medianBlur(image, blurred, 9);

    cv::Mat gray0(blurred.size(), CV_8U), gray;
    std::vector<std::vector<cv::Point> > contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++)
        {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0)
            {
//                Canny(gray0, gray, 10, 10/1.5, 3); //  5 , 150, 5//20,50,5
                Canny(gray0, gray,  5, 150, 5);
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else
            {
                gray = gray0 >= (l+1) * 255 / threshold_level;
            }
            
            // Find contours and store them in a list
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            std::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                if (approx.size() == 4 &&
                    fabs(contourArea(cv::Mat(approx))) > 1000 &&
                    isContourConvex(cv::Mat(approx)))
                {
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++)
                    {
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3)
                        rectangles.push_back(approx);
                }
            }
        }
    }
}

void getlargestRectangle(const std::vector<std::vector<cv::Point> >& rectangles, std::vector<cv::Point>& largestRectangle)
{
    if (!rectangles.size())
    {
        return;
    }
    
    double maxArea = 0;
    int index = 0;
    
    for (size_t i = 0; i < rectangles.size(); i++)
    {
        std::vector<cv::Point> approx = rectangles[i];//存放四个角坐标的数组
        if (!approx.size()) {//判空防闪退
            return;
        }
        cv::Rect rectangle = boundingRect(cv::Mat(approx));
        double area = rectangle.width * rectangle.height;
                
        if (maxArea < area)
        {
            maxArea = area;
            index = (int)i;
        }
    }
    largestRectangle = rectangles[index];
}


double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}


+(UIImage *) getTransformedImage: (CGFloat) newWidth : (CGFloat) newHeight : (UIImage *) origImage : (CGPoint [4]) corners : (CGSize) size {
    
    cv::Mat imageMat;
    
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(origImage.CGImage);
    CGFloat cols = size.width;
    CGFloat rows = size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), origImage.CGImage);
    CGContextRelease(contextRef);
    
    contextRef = nil;
    
    imageMat = cvMat;
    
    cv::Mat newImageMat = cv::Mat( cvSize(newWidth,newHeight), CV_8UC4);
    
    CGFloat disError = 4;
    cv::Point2f src[4], dst[4];
    src[0].x = corners[0].x + disError;
    src[0].y = corners[0].y + disError;
    src[1].x = corners[1].x - disError;
    src[1].y = corners[1].y + disError;
    src[2].x = corners[2].x - disError;
    src[2].y = corners[2].y - disError;
    src[3].x = corners[3].x + disError;
    src[3].y = corners[3].y - disError;
    
    dst[0].x = 0;
    dst[0].y = 0;
    dst[1].x = newWidth;
    dst[1].y = 0;
    dst[2].x = newWidth;
    dst[2].y = newHeight;
    dst[3].x = 0;
    dst[3].y = newHeight;
 
    
    
    cv::warpPerspective(imageMat, newImageMat, cv::getPerspectiveTransform(src, dst), cvSize(newWidth, newHeight));
    //Transform to UIImage
    
    NSData *data = [NSData dataWithBytes:newImageMat.data length:newImageMat.elemSize() * newImageMat.total()];
    
    CGColorSpaceRef colorSpace2;
    
    if (newImageMat.elemSize() == 1) {
        colorSpace2 = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace2 = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGFloat width = newImageMat.cols;
    CGFloat height = newImageMat.rows;
    
    CGImageRef imageRef = CGImageCreate(width,                                     // Width
                                        height,                                     // Height
                                        8,                                              // Bits per component
                                        8 * newImageMat.elemSize(),                           // Bits per pixel
                                        newImageMat.step[0],                                  // Bytes per row
                                        colorSpace2,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace2);
    
    
    cvMat.release();
    imageMat.release();
    newImageMat.release();
    return image;
}

+(UIImage *) getTransformedObjectImage: (CGFloat) newWidth : (CGFloat) newHeight : (UIImage *) origImage : (NSArray *) corners : (CGSize) size {
    
    if (size.width <= 0 || size.height <= 0) {
        return origImage;
    }
    
    cv::Mat imageMat;
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(origImage.CGImage);
    CGFloat cols = size.width;
    CGFloat rows = size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), origImage.CGImage);
    CGContextRelease(contextRef);
    
    contextRef = nil;
    
    imageMat = cvMat;
    
    cv::Mat newImageMat = cv::Mat( cvSize(newWidth,newHeight), CV_8UC4);
    
    cv::Point2f src[4], dst[4];
    for (int i = 0; i < corners.count; i ++) {
        NSValue * value = [corners objectAtIndex:i];
        src[i].x = value.CGPointValue.x;
        src[i].y = value.CGPointValue.y;
    }
    dst[0].x = 0;
    dst[0].y = 0;
    dst[1].x = newWidth;
    dst[1].y = 0;
    dst[2].x = newWidth;
    dst[2].y = newHeight;
    dst[3].x = 0;
    dst[3].y = newHeight;
 
    
    
    cv::warpPerspective(imageMat, newImageMat, cv::getPerspectiveTransform(src, dst), cvSize(newWidth, newHeight));
    //Transform to UIImage
    
    NSData *data = [NSData dataWithBytes:newImageMat.data length:newImageMat.elemSize() * newImageMat.total()];
    
    CGColorSpaceRef colorSpace2;
    
    if (newImageMat.elemSize() == 1) {
        colorSpace2 = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace2 = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGFloat width = newImageMat.cols;
    CGFloat height = newImageMat.rows;
    
    CGImageRef imageRef = CGImageCreate(width,                                     // Width
                                        height,                                     // Height
                                        8,                                              // Bits per component
                                        8 * newImageMat.elemSize(),                           // Bits per pixel
                                        newImageMat.step[0],                                  // Bytes per row
                                        colorSpace2,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace2);
    
    
    cvMat.release();
    imageMat.release();
    newImageMat.release();
    return image;
}

//从UIImage对象转换为4通道的Mat，即是原图的Mat
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+ (UIImage *)getNoShardingImage:(UIImage *)origImage {
    UIImage *image = origImage;
    cv::Mat imageMat = [self cvMatFromUIImage:image];

    Mat src = handleImageMain(imageMat);
    UIImage *newImage = [self UIImageFromCVMat:src];
    return newImage;
}

Mat handleImageMain(Mat image) {

    Mat src = image;
    //1.将图像转为灰度图 COLOR_RGB2GRAY  COLOR_BGR2GRAY
    Mat gray;
    cvtColor(src, gray, COLOR_BGR2GRAY);
    Mat blurred;
    medianBlur(gray, blurred, 3);
    //定义腐蚀和膨胀的结构化元素和迭代次数
    Mat element = getStructuringElement(MORPH_RECT, cv::Size(3, 3));
    int iteration = 9;
    
    //2.将灰度图进行膨胀操作
    Mat dilateMat;
    morphologyEx(gray, dilateMat, MORPH_DILATE, element, cv::Point(-1, -1), iteration);

    //3.将膨胀后的图再进行腐蚀
    Mat erodeMat;
    morphologyEx(dilateMat, erodeMat, MORPH_ERODE, element, cv::Point(-1, -1), iteration);

    //4.膨胀再腐蚀后的图减去原灰度图再进行取反操作
    Mat calcMat = ~(erodeMat - gray);

//    //5.使用规一化
//    Mat removeShadowMat;
//    normalize(calcMat, removeShadowMat, 0, 255, NORM_MINMAX);
    return calcMat;
}

+ (UIImage *)lightRemoveShardingImage:(UIImage *)origImage {
    UIImage *image = origImage;
    cv::Mat imageMat = [self cvMatFromUIImage:image];

    Mat src = handleRemoveShadow(imageMat);
    UIImage *newImage = [self UIImageFromCVMat:src];
    return newImage;
}

Mat handleRemoveShadow(Mat image) {

    Mat src = image;
    //1.将图像转为灰度图 COLOR_RGB2GRAY  COLOR_BGR2GRAY
    Mat gray;
    cvtColor(src, gray, COLOR_BGR2GRAY);
    Mat blurred;
    medianBlur(gray, blurred, 3);
    //定义腐蚀和膨胀的结构化元素和迭代次数
    Mat element = getStructuringElement(MORPH_RECT, cv::Size(12, 12));
    int iteration = 3;
    
//    //2.将灰度图进行膨胀操作
//    Mat dilateMat;
//    morphologyEx(gray, dilateMat, MORPH_DILATE, element, cv::Point(-1, -1), iteration);
//
//    //3.将膨胀后的图再进行腐蚀
//    Mat erodeMat;
//    morphologyEx(dilateMat, erodeMat, MORPH_ERODE, element, cv::Point(-1, -1), iteration);
    
    //2.将灰度图进行闭运算操作
    Mat closeMat;
    morphologyEx(blurred, closeMat, MORPH_CLOSE, element, cv::Point(-1, -1), iteration);

    //4.膨胀再腐蚀后的图减去原灰度图再进行取反操作
//    Mat calcMat = ~(erodeMat - gray);
    Mat calcMat = ~(closeMat - blurred);

    //5.使用规一化
    Mat removeShadowMat;
    normalize(calcMat, removeShadowMat, 0, 255, NORM_MINMAX);
    return removeShadowMat;
}

+ (UIImage *)getGrayThresholdImage:(UIImage *)origImage {
    UIImage *image = origImage;
    cv::Mat imageMat = [self cvMatFromUIImage:image];
    Mat src = handleThresholdImage(imageMat);
    UIImage *newImage = [self UIImageFromCVMat:src];
    return newImage;
}

Mat handleThresholdImage(Mat image) {

    Mat src = image;
    //1.将图像转为灰度图 COLOR_RGB2GRAY  COLOR_BGR2GRAY
    Mat gray;
    cvtColor(src, gray, COLOR_BGR2GRAY);
    Mat blurred;
    GaussianBlur(gray, blurred, cvSize(3, 3), 0);
//    //2.将图像二值化处理(自适应阈值)
    Mat threshold;
    adaptiveThreshold(blurred, threshold, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY, 55, 18);

    return threshold;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
