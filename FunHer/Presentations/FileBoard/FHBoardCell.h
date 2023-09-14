//
//  FHBoardCell.h
//  FunHer
//
//  Created by GLA on 2023/9/14.
//

#import <UIKit/UIKit.h>

@class FHBoardCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHBoardCell : UITableViewCell

- (void)configCellWithData:(FHBoardCellModel *)fileTargetModel;

@end

NS_ASSUME_NONNULL_END
