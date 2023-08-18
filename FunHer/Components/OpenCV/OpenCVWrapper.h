//
//  OpenCVWrapper.h
//  CamScanner
//
//  Created by Srinija on 16/05/17.
//  Copyright © 2017 Srinija Ammapalli. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject
+(NSMutableArray *) getLargestSquarePoints: (UIImage *) image : (CGSize) size :(BOOL)isAutomatic;
+(UIImage *) getTransformedImage: (CGFloat) newWidth : (CGFloat) newHeight : (UIImage *) origImage : (CGPoint [4]) corners : (CGSize) size;
+(UIImage *) getTransformedObjectImage: (CGFloat) newWidth : (CGFloat) newHeight : (UIImage *) origImage : (NSArray *) corners : (CGSize) size;

/// 去阴影
/// @param origImage  原图
+(UIImage *)getNoShardingImage:(UIImage *) origImage;

/// 去阴影
/// @param origImage  原图
+(UIImage *)lightRemoveShardingImage:(UIImage *) origImage;

/// 二值化
/// @param origImage  原图
+ (UIImage *)getGrayThresholdImage:(UIImage *)origImage;

@end
