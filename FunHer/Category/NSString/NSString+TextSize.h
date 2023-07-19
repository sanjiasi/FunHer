//
//  NSString+TextSize.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TextSize)

/// 计算文字的宽度
/// @param font 字体(默认为系统字体)
/// @param height 约束高度
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

/// 计算文字的高度
/// @param font 字体(默认为系统字体)
/// @param width 约束宽度
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
