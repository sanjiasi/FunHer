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
@property (nonatomic, strong) UIImageView *showImg;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *uTimeLab;
@property (nonatomic, strong) UILabel *numLab;


@end

NS_ASSUME_NONNULL_END
