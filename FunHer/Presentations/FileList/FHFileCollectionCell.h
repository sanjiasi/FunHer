//
//  FHFileCollectionCell.h
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import <UIKit/UIKit.h>
#import "FHFileListPresent.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFileCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *showImg;//封面图
@property (nonatomic, strong) UILabel *titleLab;//名称
@property (nonatomic, strong) UILabel *uTimeLab;//日期
@property (nonatomic, strong) UILabel *numLab;//文件个数


@end

NS_ASSUME_NONNULL_END
