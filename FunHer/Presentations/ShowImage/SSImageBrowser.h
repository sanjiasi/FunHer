//
//  SSImageBrowser.h
//  SimpleScan
//
//  Created by GLA on 2021/11/1.
//  Copyright © 2021 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSImageBrowser : UIView
//数据源
@property (nonatomic, strong) NSMutableArray *dataArray;
//当前点击的图片下标
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) void(^refreshCurrentIndex)(NSInteger index);//当前的位置

- (void)updateCurrentItem;
- (void)hiddenPageLab;
@end

NS_ASSUME_NONNULL_END
