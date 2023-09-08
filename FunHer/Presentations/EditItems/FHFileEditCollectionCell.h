//
//  UIFileEditCollectionCell.h
//  FunHer
//
//  Created by GLA on 2023/9/8.
//

#import <UIKit/UIKit.h>

@class FHFileEditCellModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHFileEditCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *showImg;//封面图
@property (nonatomic, strong) UILabel *titleLab;//名称
@property (nonatomic, strong) UILabel *uTimeLab;//日期
@property (nonatomic, strong) UILabel *numLab;//文件个数
@property (nonatomic, strong) UIImageView *folderIcon;//文件夹图标
@property (nonatomic, strong) UIImageView *checkBox;//选中标记
@property (nonatomic, strong) UIView *maskView;//蒙层
@property (nonatomic, strong) FHFileEditCellModel *cellModel;


@end

NS_ASSUME_NONNULL_END
