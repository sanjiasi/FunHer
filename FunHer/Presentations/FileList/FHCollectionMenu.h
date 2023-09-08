//
//  FHCollectionMenu.h
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ClickForAction)(NSInteger idx, NSString *selector);

@interface FHCollectionMenu : UIView
@property (nonatomic, strong) UIColor *bgColor;

/// item: {image, title, selector}
- (instancetype)initWithItems:(NSArray *)itemArr menuHeight:(CGFloat)height actionBlock:(ClickForAction)action;

@end

NS_ASSUME_NONNULL_END
