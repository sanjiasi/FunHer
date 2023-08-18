//
//  SSFaxImageBrowserVC.h
//  SimpleScan
//
//  Created by GLA on 2021/12/14.
//  Copyright © 2021 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSFaxImageBrowserVC : UIViewController

@property (nonatomic, copy) NSString *fileName;
//数据源
@property (nonatomic, strong) NSMutableArray *dataArray;
//当前点击的图片下标
@property (nonatomic, assign) NSInteger currentIndex;
//把数组里的数据都删除之后的回调
@property (nonatomic, copy) void (^deleteAllDataBlock)(void);

@end

NS_ASSUME_NONNULL_END
