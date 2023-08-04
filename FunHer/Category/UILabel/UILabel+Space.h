//
//  UILabel+Space.h
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Space)

/// 改变行间距
/// - Parameters:
///   - space: 设置间距
- (void)reSetLineSpace:(CGFloat)space;

/// 改变字间距
/// - Parameter space: 设置间距
- (void)reSetWordSpace:(CGFloat)space;

/// 改变行间距和字间距
/// - Parameters:
///   - lineSpace: 行间距
///   - wordSpace: 字间距
- (void)reSetLineSpace:(CGFloat)lineSpace wordSpace:(CGFloat)wordSpace;

@end

NS_ASSUME_NONNULL_END
