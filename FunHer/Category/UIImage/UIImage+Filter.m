//
//  UIImage+Filter.m
//  FunHer
//
//  Created by GLA on 2023/8/25.
//

#import "UIImage+Filter.h"
#import <GPUImage/GPUImage.h>
#import "UIImage+Orientation.h"
#import "OpenCVWrapper.h"

@implementation UIImage (Filter)

#pragma mark -- 灰度图
+ (UIImage *)filterByGrayscaleImage:(UIImage *)image {
    GPUImagePicture *imageGPU = [self imageGPU:image];
    //使用灰色滤镜
    GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc] init];
    //添加滤镜
    [imageGPU addTarget:filter];
    [filter useNextFrameForImageCapture];
    //开始渲染
    [imageGPU processImage];
    //获取渲染后的图片
    UIImage *newImg = [filter imageFromCurrentFramebufferWithOrientation:image.imageOrientation];

    [imageGPU removeAllTargets];
    [filter removeAllTargets];
    imageGPU = nil;
    filter = nil;
    return newImg;
}

+ (UIImage *)filterByNostalgicImage:(UIImage *)image {
    GPUImagePicture *imageGPU = [self imageGPU:image];
    //使用怀旧滤镜
    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
    [imageGPU addTarget:filter];
    [filter useNextFrameForImageCapture];
    //开始渲染
    [imageGPU processImage];
    //获取渲染后的图片
    UIImage *newImg = [filter imageFromCurrentFramebufferWithOrientation:image.imageOrientation];

    [imageGPU removeAllTargets];
    [filter removeAllTargets];
    imageGPU = nil;
    filter = nil;
    return newImg;
}

+ (UIImage *)filterByMagicColorImage:(UIImage *)image {
    GPUImagePicture *imageGPU = [self imageGPU:image];
    //单色 根据每个像素的亮度将图像转换为单色版本
    GPUImageMonochromeFilter *monoFilter = [[GPUImageMonochromeFilter alloc] init];
    [monoFilter setColorRed:1.0 green:1.0 blue:1.0];
    monoFilter.intensity = 0.6;//特定颜色替换正常图像颜色的程度（0.0 - 1.0)，默认为1.0
    
    //亮度：调整亮度（-1.0 - 1.0，默认为0.0）
    GPUImageBrightnessFilter *brightFilter = [[GPUImageBrightnessFilter alloc]init];
    brightFilter.brightness = 0.1;
    
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc]init];
    saturationFilter.saturation = 2.0;
    
    //色彩增强 用于添加或删除雾度（类似于UV过滤器）    distance：应用的颜色的强度。-.3和.3之间的值最好。          斜率：颜色变化量。-.3和.3之间的值最好
    GPUImageHazeFilter *corlrBurnFilter = [[GPUImageHazeFilter alloc]init];
    corlrBurnFilter.distance = 0.3;
    corlrBurnFilter.slope = 0.1;
    
    NSMutableArray * filterArray = [NSMutableArray new];
    [filterArray addObject:monoFilter];
    [filterArray addObject:brightFilter];
    [filterArray addObject:saturationFilter];
    [filterArray addObject:corlrBurnFilter];
    
    GPUImageFilterPipeline *pipelineFilter = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:filterArray input:imageGPU output:nil];
    [corlrBurnFilter useNextFrameForImageCapture];
    //开始渲染
    [imageGPU processImage];
    UIImage *newImg = [pipelineFilter currentFilteredFrameWithOrientation:image.imageOrientation];
    [imageGPU removeAllTargets];
    [pipelineFilter removeAllFilters];
    imageGPU = nil;
    pipelineFilter = nil;
    return newImg;
}

+ (UIImage *)filterByBWImage:(UIImage *)image {
    image = image.fixUpOrientation;
    UIImage *newImg = [OpenCVWrapper getGrayThresholdImage:image];
    return newImg;
}

+ (UIImage *)filterByNoShadowImage:(UIImage *)image {
    UIImage *noShadingImg = [OpenCVWrapper getNoShardingImage:image];
    GPUImagePicture *imageGPU = [self imageGPU:noShadingImg];
    GPUImageToneCurveFilter *toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
    [toneCurveFilter setRgbCompositeControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.50, 0.0)], [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]]];

    GPUImageLevelsFilter *levelsFilter = [[GPUImageLevelsFilter alloc] init];
    [levelsFilter setMin:0.40 gamma:0.50 max:0.65];
    NSMutableArray * filterArray = [NSMutableArray new];
    [filterArray addObject:toneCurveFilter];
    [filterArray addObject:levelsFilter];
    
    
    //组合滤镜
    GPUImageFilterPipeline * pipelineFilter = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:filterArray input:imageGPU output:nil];
    [levelsFilter useNextFrameForImageCapture];
    //开始渲染
    [imageGPU processImage];
    UIImage *newImg = [pipelineFilter currentFilteredFrameWithOrientation:image.imageOrientation];
    [imageGPU removeAllTargets];
    [pipelineFilter removeAllFilters];
    imageGPU = nil;
    pipelineFilter = nil;
    return newImg;
}

#pragma mark -- 清理GPU缓存
+ (void)clearGPUCache {
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
}

#pragma mark -- 构造GPUImagePicture
+ (GPUImagePicture *)imageGPU:(UIImage *)image {
    GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:image];
    return source;
}

@end
