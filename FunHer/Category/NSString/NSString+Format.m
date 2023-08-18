//
//  NSString+Format.m
//  FunHer
//
//  Created by GLA on 2023/8/18.
//

#import "NSString+Format.h"

@implementation NSString (Format)

+ (NSString *)memorySizeFormat:(float)totalSize {// 最大保留2位小数
    float unitRate = 1024.0;
    float foldSize = totalSize / (unitRate * unitRate);
    float foldSize1= totalSize / unitRate;
    float flodSize2 = totalSize / (unitRate*unitRate*unitRate);
    if (foldSize < 1) {//就显示kb
        NSString * tempfloat = [NSString stringWithFormat:@"%0.2f",foldSize1];
        return [NSString stringWithFormat:@"%@K",@(tempfloat.floatValue)];
    } else if (foldSize >=1  && foldSize < unitRate) {//就显示M
        NSString * tempfloat = [NSString stringWithFormat:@"%0.2f",foldSize];
        return [NSString stringWithFormat:@"%@M",@(tempfloat.floatValue)];
    } else { //就显示G
        NSString * tempfloat = [NSString stringWithFormat:@"%0.2f",flodSize2];
        return [NSString stringWithFormat:@"%@G",@(tempfloat.floatValue)];// 末尾清零
    }
}

@end
