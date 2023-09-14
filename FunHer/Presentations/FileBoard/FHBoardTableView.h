//
//  FHBoardTableView.h
//  FunHer
//
//  Created by GLA on 2023/9/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHBoardTableView : UITableView
/**
 数据源
 */
@property (copy, nonatomic) NSArray *dataArray;

@property (nonatomic, copy) void(^didSelectFileBlock)(NSIndexPath *aIndex);

@end

NS_ASSUME_NONNULL_END
