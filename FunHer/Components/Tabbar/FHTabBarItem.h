//
//  FHBarButton.h
//  FunHer
//
//  Created by GLA on 2023/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHTabBarItem : UICollectionViewCell
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *mask;
@property (nonatomic, strong) UIImageView *showImg;//封面图
@property (nonatomic, strong) UILabel *titleLab;//名称
@property (nonatomic, assign) BOOL enable;//Yes：可以点  No：不能点

@end

NS_ASSUME_NONNULL_END
