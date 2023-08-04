//
//  FHImageCollectionCell.h
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHImageCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *showImg;//封面图
@property (nonatomic, strong) UILabel *titleLab;//名称

@end

NS_ASSUME_NONNULL_END
