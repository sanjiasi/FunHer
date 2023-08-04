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
/// item: {image, title, selector}
- (instancetype)initWithItems:(NSArray *)itemArr actionBlock:(ClickForAction)action;

@end

NS_ASSUME_NONNULL_END
