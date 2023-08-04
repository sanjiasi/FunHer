//
//  PhotoEditScrollView.h
//  SimpleScan
//
//  Created by admin3 on 2020/6/8.
//  Copyright © 2020 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoEditScrollView : UIScrollView

@property (nonatomic, copy) void(^photoClickSingleHandler)(void);

@property (nonatomic, copy) void(^photoClickZoomHandler)(void);
@property (nonatomic, copy) void(^photoWillBeginDragging)(void);
@property (nonatomic, copy) void(^photoDidEndDecelerating)(void);

@property (nonatomic, copy) void(^photoZoomScale)(CGFloat zoomScale);

/**
 本地图片
 */
@property (nonatomic, strong) UIImage *mainImage;

/**
 图片显示
 */
@property (nonatomic, strong) UIImageView *mainImageView;
@end

NS_ASSUME_NONNULL_END
