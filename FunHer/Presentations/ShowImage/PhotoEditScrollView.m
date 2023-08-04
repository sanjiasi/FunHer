//
//  PhotoEditScrollView.m
//  SimpleScan
//
//  Created by admin3 on 2020/6/8.
//  Copyright © 2020 admin3. All rights reserved.
//

#import "PhotoEditScrollView.h"
@interface PhotoEditScrollView()<UIScrollViewDelegate>

/**
 当前图片偏移量
 */
@property (nonatomic,assign) CGPoint currPont;

@end


@implementation PhotoEditScrollView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup{
//    self.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.2];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.maximumZoomScale = 3;
    self.minimumZoomScale = 1;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = NO;
//    self.layer.masksToBounds = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.mainImageView];

    _currPont = CGPointZero;


    ///单击
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSingleSponse:)];
    //设置手势属性
    tapSingle.numberOfTapsRequired = 1;
    tapSingle.delaysTouchesEnded = NO;
    [self.mainImageView addGestureRecognizer:tapSingle];

    
    ///双击
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDoubleSponse:)];
    //设置手势属性
    tapDouble.numberOfTapsRequired = 2;
    [self.mainImageView addGestureRecognizer:tapDouble];
    ///避免手势冲突
     [tapSingle requireGestureRecognizerToFail:tapDouble];
}

#pragma mark - layoutSubviews
- (void)layoutSubviews{
    [super layoutSubviews];
    ///放大或缩小中
    if (self.zooming || self.zoomScale != 1.0 || self.zoomBouncing) {
        return;
    }
    
    ///设置图片尺寸
    if (_mainImage.size.width>0&&_mainImage.size.height>0) {
        CGRect imgRect = [self getImageViewFrame];
        self.mainImageView.frame = imgRect;
        ///设置content size
        if (CGRectGetHeight(imgRect) > CGRectGetHeight(self.frame)) {
            [self setContentSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(imgRect))];
        }else{
            [self setContentSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        }
    }
    
}
- (void)setMainImage:(UIImage *)mainImage{
    if (mainImage.size.width>0&&mainImage.size.height>0) {
        _mainImage = mainImage;
        self.mainImageView.image = _mainImage;
        [self setContentOffset:CGPointMake(0, 0)];
        [self setNeedsLayout];
    }
}

/**
 根据图片原始大小，获取图片显示大小
 @return CGRect
 */
- (CGRect)getImageViewFrame{
    if (_mainImage.size.width>0&&_mainImage.size.height>0) {
        UIImage *imageTy = _mainImage;
        float imgWidth = 0;
        float imgHeight = 0;
        
        CGFloat fatherWidth = self.frame.size.width;
        CGFloat fatherHeight = CGRectGetHeight(self.frame);
        if  (imageTy.size.width/imageTy.size.height >= fatherWidth/fatherHeight) {
            imgWidth = fatherWidth;
            imgHeight = imgWidth / imageTy.size.width * imageTy.size.height;
        } else {
            imgHeight = fatherHeight;
            imgWidth = imgHeight / imageTy.size.height * imageTy.size.width;
        }
        return CGRectMake((fatherWidth-imgWidth)/2, (fatherHeight-imgHeight)/2, imgWidth, imgHeight);
    }else{
        return self.frame;
    }
}
/**
 获取点击位置后所需的偏移量【目的是呈现点击位置在试图上】
 
 @param location 点击位置
 */
- (void)zoomingOffset:(CGPoint)location{
    CGFloat lo_x = location.x * self.zoomScale;
    CGFloat lo_y = location.y * self.zoomScale;
    
    CGFloat off_x;
    CGFloat off_y;
    ///off_x
    if (lo_x < CGRectGetWidth(self.frame)/2) {
        off_x = 0;
    }
    else if (lo_x > self.contentSize.width - CGRectGetWidth(self.frame)/2){
        off_x = self.contentSize.width - CGRectGetWidth(self.frame);
    }
    else{
        off_x = lo_x - CGRectGetWidth(self.frame)/2;
    }
    
    ///off_y
    if (lo_y < CGRectGetHeight(self.frame)/2) {
        off_y = 0;
    }
    else if (lo_y > self.contentSize.height - CGRectGetHeight(self.frame)/2){
        if (self.contentSize.height <= CGRectGetHeight(self.frame)) {
            off_y = 0;
        }
        else{
            off_y = self.contentSize.height - CGRectGetHeight(self.frame);
        }
        
    }
    else{
        off_y = lo_y - CGRectGetHeight(self.frame)/2;
    }
    [self setContentOffset:CGPointMake(off_x, off_y)];
}

#pragma mark - 重置图片
- (void)resetImageViewState{
    self.zoomScale = 1;
    _mainImage = nil;;
    self.mainImageView.image = nil;
   
}
#pragma mark - 变量
- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [UIImageView new];
        _mainImageView.image = nil;
        _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        _mainImageView.userInteractionEnabled = YES;

    }
    return _mainImageView;
}


#pragma mark - 单击
- (void)tapSingleSponse:(UITapGestureRecognizer *)singleTap{
    if (!self.mainImageView.image) {
        return;
    }

//    if (self.zoomScale != 1) {
//        [UIView animateWithDuration:0.2 animations:^{
//            self.zoomScale = 1;
//        } completion:^(BOOL finished) {
//            [self setContentOffset:self->_currPont animated:YES];
//        }];
//    }
    if (self.photoClickSingleHandler) {
        self.photoClickSingleHandler();
    }
}
#pragma mark - 双击
- (void)tapDoubleSponse:(UITapGestureRecognizer *)doubleTap{
    if (!self.mainImageView.image) {
        return;
    }
    CGPoint point = [doubleTap locationInView:self.mainImageView];
    if (self.zoomScale == 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.zoomScale = 2.0;
            [self zoomingOffset:point];
//            self.mainImageView.transform = CGAffineTransformScale(self.mainImageView.transform,2.0, 2.0);
        }];
    }
    else{
        [UIView animateWithDuration:0.2 animations:^{
            self.zoomScale = 1;
//            self.mainImageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self setContentOffset:self->_currPont animated:YES];
        }];
    }
    
    if (self.photoClickZoomHandler) {
        self.photoClickZoomHandler();
    }
    
    if (self.photoZoomScale) {
        self.photoZoomScale(self.zoomScale);
    }
     
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    if (self.photoClickZoomHandler) {
        self.photoClickZoomHandler();
    }
}
    
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

    if (!self.mainImageView.image) {
        return;
    }
    
    CGRect imageViewFrame = self.mainImageView.frame;
    CGFloat width = imageViewFrame.size.width,
    height = imageViewFrame.size.height,
    sHeight = scrollView.bounds.size.height,
    sWidth = scrollView.bounds.size.width;
    if (height > sHeight) {
        imageViewFrame.origin.y = 0;
    } else {
        imageViewFrame.origin.y = (sHeight - height) / 2.0;
    }
    if (width > sWidth) {
        imageViewFrame.origin.x = 0;
    } else {
        imageViewFrame.origin.x = (sWidth - width) / 2.0;
    }
    self.mainImageView.frame = imageViewFrame;
    if (self.photoZoomScale) {
        self.photoZoomScale(self.zoomScale);
    }
    /*
    CGFloat factor = self.zoomScale;
    CGRect imgViewFrame = self.mainImageView.frame;
    static CGFloat lastScale=1;
    CGFloat currentScale = [[self.mainImageView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    const CGFloat kMaxScale = 3.0;
    CGFloat newScale = 1 -  (lastScale - factor);
    newScale = MIN(newScale, kMaxScale / currentScale);
    
    imgViewFrame.size.width = imgViewFrame.size.width * newScale;
    imgViewFrame.size.height = imgViewFrame.size.height * newScale;
    imgViewFrame.origin.x = self.mainImageView.center.x - imgViewFrame.size.width/2;
    imgViewFrame.origin.y = self.mainImageView.center.y - imgViewFrame.size.height/2;
 
    CGAffineTransform transformN = CGAffineTransformScale(self.mainImageView.transform, newScale, newScale);
    self.mainImageView.transform = transformN;
    lastScale = factor;
    self.mainImageView.frame = imgViewFrame;
    */
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainImageView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isZooming || self.zoomScale != 1) {
        return;
    }
    _currPont = scrollView.contentOffset;
    if (self.photoDidEndDecelerating) {
        self.photoDidEndDecelerating();
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.photoWillBeginDragging) {
        self.photoWillBeginDragging();
    }
}
/*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.photoDidEndDecelerating) {
        self.photoDidEndDecelerating();
    }
}
 */
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return YES;
//}

@end
