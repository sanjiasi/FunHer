//
//  FHPDFTool.m
//  FunHer
//
//  Created by GLA on 2023/9/5.
//

#import "FHPDFTool.h"

@implementation FHPDFTool

+ (NSArray *)splitPDF:(NSURL *)url {
    NSString *docPath = [NSString tempPDFForImageDir];
    NSArray *pathArr = [self splitPDF:url atDoc:docPath];
    return pathArr;
}

+ (NSArray *)splitPDF:(NSURL *)url atDoc:(NSString *)path {
    CGPDFDocumentRef aPDFRef = CGPDFDocumentCreateWithURL((CFURLRef)url);
    if (aPDFRef == NULL || (CGPDFDocumentIsEncrypted (aPDFRef))) {
        CFRelease((__bridge CFURLRef)url);
        return @[];
    }
    NSInteger page = CGPDFDocumentGetNumberOfPages(aPDFRef);
    NSMutableArray *pathArr = @[].mutableCopy;
    for (int i = 1; i<=page; i++) {
        @autoreleasepool {
            UIImage *image = [self getPDFImage:aPDFRef index:i];//
            NSString *fileName = [NSString stringWithFormat:@"%@_%@%@",[NSString imageName], @(i), FHFilePathExtension];
            NSString *imgPath = [path stringByAppendingPathComponent:fileName];
            [UIImage saveImage:image atPath:imgPath];
            [pathArr addObject:fileName];
        }
    }
    CGPDFDocumentRelease(aPDFRef);
    return pathArr;
}

+ (UIImage *)getPDFImage:(CGPDFDocumentRef)fromPDFDoc index:(NSInteger)i {
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(fromPDFDoc, i);
    CGPDFPageRetain(pageRef);
    // determine the size of the PDF page
    CGFloat pixe = [UIScreen mainScreen].scale;
    DELog(@"pixe==%.2f yyy==%.2f",pixe,kScreenHeight*1.0/kScreenWidth);
    CGFloat scaleCustom = 3;
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox);
    // renders its content.
    CGFloat imagePiexl = (pageRect.size.width*scaleCustom) * (pageRect.size.height*scaleCustom);
    CGFloat SSMaxPiexl = 8000000.0;
    if (imagePiexl > SSMaxPiexl) {//图片过大需要压缩 SSMaxPiexl
        float rate = imagePiexl / SSMaxPiexl;
        float scale = sqrtf(rate);
        CGFloat sizeH =  pageRect.size.height*scaleCustom/ scale;
        CGFloat sizeW = pageRect.size.width *scaleCustom/ scale;
        pageRect.size.height= sizeH;
        pageRect.size.width= sizeW;
    }else{
        pageRect.size.height= pageRect.size.height*scaleCustom;
        pageRect.size.width= pageRect.size.width*scaleCustom;
    }
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef imgContext = UIGraphicsGetCurrentContext();
    //设置白色背景
    CGContextSetRGBFillColor(imgContext, 1.0,1.0,1.0,1.0);
    CGContextFillRect(imgContext,pageRect);
//    CGContextSaveGState(imgContext);
    CGContextTranslateCTM(imgContext, -pageRect.size.width*((scaleCustom-1)/2), pageRect.size.height*(scaleCustom/2+0.5));
    CGContextScaleCTM(imgContext,scaleCustom, -scaleCustom);
    CGContextSetRenderingIntent(imgContext, kCGRenderingIntentDefault);
    CGContextSetInterpolationQuality(imgContext, kCGInterpolationDefault);
    CGContextConcatCTM(imgContext, CGPDFPageGetDrawingTransform(pageRef, kCGPDFMediaBox, pageRect,0,true));
    CGContextDrawPDFPage(imgContext, pageRef);
//    CGContextRestoreGState(imgContext);
    //PDF Page to image
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //Release current source page
    CGPDFPageRelease(pageRef);
    pageRef = NULL;
    return tempImage;
}

@end
