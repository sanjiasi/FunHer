//
//  FHMagnifierView.m
//  FunHer
//
//  Created by GLA on 2023/8/17.
//

#import "FHMagnifierView.h"

@implementation FHMagnifierView

-(instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        _aimSize = 10;
        _aimColor = kBlackColor;
        [KAppWindow addSubview:self];
        
        self.frame = CGRectMake(0, 0, 120, 120);
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1;
        UIColor *borderColor = [UIColor grayColor];
        self.layer.borderColor = borderColor.CGColor;
        self.layer.cornerRadius = 120/2;
        self.layer.masksToBounds = YES;
        self.hidden = YES;
    }
    return self;
}


- (void)setAimSize:(CGFloat)aimSize {
    _aimSize = aimSize;
    [self.layer setNeedsDisplay];
}

- (void)setAimColor:(UIColor *)aimColor {
    _aimColor = aimColor;
    [self.layer setNeedsDisplay];
}

- (CAShapeLayer *)aimLine {
    if (!_aimLine) {
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.bounds = self.bounds;
        lineLayer.lineWidth = 1.0;
        lineLayer.fillColor  = nil;   //  默认是black
        _aimLine = lineLayer;
    }
    return _aimLine;
}

#pragma mark -- 放大镜准心
- (void)aimPint:(CGPoint)centerPoint {
    //   创建一个路径对象
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    CGFloat dotSize = self.aimSize;
    //  起点
    [linePath moveToPoint:(CGPoint){centerPoint.x - dotSize, centerPoint.y}];
    // 其他点
    [linePath addLineToPoint:(CGPoint){centerPoint.x + dotSize, centerPoint.y}];
    
    UIBezierPath *verticalPath = [UIBezierPath bezierPath];
    //  起点
    [verticalPath moveToPoint:(CGPoint){centerPoint.x, centerPoint.y - dotSize}];
    // 其他点
    [verticalPath addLineToPoint:(CGPoint){centerPoint.x, centerPoint.y + dotSize}];
    [linePath appendPath:verticalPath];
    
    //  设置路径画布
    if (_aimLine) {
        [self.aimLine removeFromSuperlayer];
        self.aimLine = nil;
    }
    //  设置路径画布
    self.aimLine.position = centerPoint;
    self.aimLine.strokeColor = self.aimColor.CGColor;
    self.aimLine.path = linePath.CGPath;
    [self.layer addSublayer:self.aimLine];
}

#pragma mark set the point of magnifier
- (void)setPointTomagnify:(CGPoint)pointTomagnify {
    _pointTomagnify = pointTomagnify;
    CGPoint center = CGPointMake(pointTomagnify.x, self.center.y);
    if (pointTomagnify.y > CGRectGetHeight(self.bounds) * 0.5) {
        center.y = pointTomagnify.y - CGRectGetHeight(self.bounds)/2+80;
    }
    if (pointTomagnify.x > kScreenWidth / 2) {
        self.center = CGPointMake(60+5, 100);
    } else {
        self.center = CGPointMake(kScreenWidth - (60+5), 100);
    }

    [self.layer setNeedsDisplay];
}

#pragma mark  invoke  by setNeedDisplay
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    float width = CGRectGetWidth(self.frame);
    float height = CGRectGetHeight(self.frame);
    
    //宽高
    CGContextTranslateCTM(ctx,width * 0.5, height * 0.5);
    //缩放比例
    CGContextScaleCTM(ctx, 2.5, 2.5);
    //x y 坐标转换
    CGContextTranslateCTM(ctx, -self.pointTomagnify.x, -self.pointTomagnify.y);
    //截屏并显示
    [self.magnifyView.layer renderInContext:ctx];
    [self aimPint:CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2)];
}


@end
