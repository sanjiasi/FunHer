//
//  ShowPicCollectionViewCell.m
//  SimpleScan
//
//  Created by admin3 on 2020/9/8.
//  Copyright © 2020 admin3. All rights reserved.
//

#import "ShowPicCollectionViewCell.h"
#import "FHImageCellModel.h"

@implementation ShowPicCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        __weak typeof(self) weakSelf = self;
        _zoomView = [[PhotoEditScrollView alloc]init];
        _zoomView.backgroundColor = RGB(240, 240, 240);
        _zoomView.userInteractionEnabled = YES;
        _zoomView.photoClickSingleHandler = ^{
            [weakSelf currentItemAction];
        };
        
        _zoomView.photoClickZoomHandler = ^{
            [weakSelf currentZoomAction];
        };
        
        _zoomView.photoWillBeginDragging = ^{
            if (weakSelf.scrollBeginShow) {
                weakSelf.scrollBeginShow();
            }
        };
        
        _zoomView.photoDidEndDecelerating = ^{
            if (weakSelf.scrollEndHide) {
                weakSelf.scrollEndHide();
            }
        };
        _zoomView.photoZoomScale = ^(CGFloat zoomScale) {
            [weakSelf judgeZoomScale:zoomScale];
        };
        [self.contentView addSubview:_zoomView];
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    [_zoomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentView);
    }];
}

- (void)setModel:(FHImageCellModel *)model{
    _model = model;
    _zoomView.zoomScale = 1.0;
    _zoomView.mainImage = [UIImage imageWithContentsOfFile:model.thumbNail];
}


- (void)judgeZoomScale:(CGFloat)zoomScale{
    if (self.sendZoomScale) {
        self.sendZoomScale(zoomScale);
    }
}
- (void)currentItemAction{
    if (self.clickItem) {
        self.clickItem();
    }
}

- (void)currentZoomAction{
    if (self.clickZoom) {
        self.clickZoom();
    }
}

@end
