//
//  FHTabbar.h
//  FunHer
//
//  Created by GLA on 2023/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ClickForAction)(NSInteger idx, NSString *selector);

@interface FHTabbar : UIView

@property (nonatomic, strong) UIColor *bgColor;

/// item: {image, title, selector}
- (instancetype)initWithItems:(NSArray *)itemArr menuHeight:(CGFloat)height actionBlock:(ClickForAction)action;

- (void)reloadWithItems:(NSArray *)itemArr;

@end

NS_ASSUME_NONNULL_END
