//
//  UIButton+LongTap.h
//  SimpleScan
//
//  Created by GLA on 2020/12/1.
//  Copyright © 2020 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (LongTap)

- (void)addLongTapWithTarget:(id)target action:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
