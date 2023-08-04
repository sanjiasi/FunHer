//
//  ShowPicCollectionViewCell.h
//  SimpleScan
//
//  Created by admin3 on 2020/9/8.
//  Copyright © 2020 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoEditScrollView.h"

@class FHImageCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface ShowPicCollectionViewCell : UICollectionViewCell
@property (nonatomic ,strong)PhotoEditScrollView * zoomView;
@property (nonatomic ,strong)FHImageCellModel * model;
@property (nonatomic ,strong)NSString * cameraImagePath;
@property (nonatomic ,strong)NSString * cameraBatchImagePath;
@property (nonatomic ,copy)void (^clickItem)(void);
@property (nonatomic ,copy)void (^clickZoom)(void);
@property (nonatomic ,copy)void(^sendZoomScale)(CGFloat zoomScale);
@property (nonatomic ,copy)void(^scrollBeginShow)(void);
@property (nonatomic ,copy)void(^scrollEndHide)(void);
@end

NS_ASSUME_NONNULL_END
