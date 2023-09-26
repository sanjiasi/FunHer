//
//  SSImageBrowser.m
//  SimpleScan
//
//  Created by GLA on 2021/11/1.
//  Copyright © 2021 admin3. All rights reserved.
//

#define Bottom_H 60

#import "SSImageBrowser.h"
#import "ShowPicCollectionViewCell.h"

@interface SSImageBrowser ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate> {
    BOOL isShowEditView;
    BOOL isZoom;//缩放图片时作为不走scrollView滑动结束的代理方法的判定属性
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, assign) CGFloat pagH;

@end

@implementation SSImageBrowser

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGB(240, 240, 240);
        isShowEditView = YES;
        isZoom = YES;
        self.pagH = 23;
        [self configContentView];
    }
    return self;
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    [self.collectionView reloadData];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    if (_pageLabel) {
//        self.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.currentIndex + (long)1),(unsigned long)self.dataArray.count];
        [self defaultPageLabFream];
    }
}

- (void)updateCurrentItem {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//添加0.05s延迟 防止动画效果冲突
        [self.collectionView setContentOffset:CGPointMake(self.currentIndex * kScreenWidth,0) animated:NO];
    });
}

- (void)configContentView {
    [self addSubview:self.collectionView];
    [self addSubview:self.pageLabel];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
}

#pragma mark -- collectionView delegate & dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    ShowPicCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ShowPicCollectionViewCell class]) forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.item];
    cell.sendZoomScale = ^(CGFloat zoomScale) {
        [weakSelf setCollectionScrollState:zoomScale];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kScreenWidth, kScreenHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -- 当图片在放缩状态时不让collectionView滑动
- (void)setCollectionScrollState:(CGFloat)zoomScale {
    if (zoomScale == 1.0) {
        self.collectionView.scrollEnabled = YES;
    }else{
        self.collectionView.scrollEnabled = NO;
    }
}

- (void)resetcollectionViewContent{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - UIScrollViewDelegate
#pragma mark -- 停止拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        [self setcurrentPage:pageIndex];
    }
}
#pragma mark -- 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        self.currentIndex = pageIndex;
        self->isZoom = YES;
    }
}
#pragma mark -- 滑动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        if (self->isZoom) {//缩放图片时不能走下面的内容 点击图片 左右滑动图片都可以走
            [self setcurrentPage:pageIndex];
        }
    }
}

- (void)setcurrentPage:(NSInteger)pageIndex{
    self.currentIndex = pageIndex;
    [self defaultPageLabFream];
    if (self.currentIndex < self.dataArray.count) {
        if (self.refreshCurrentIndex) {
            self.refreshCurrentIndex(self.currentIndex);
        }
    }
}

- (void)hiddenPageLab {
    self.pageLabel.hidden = YES;
}

- (void)defaultPageLabFream {
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.currentIndex + (long)1),(unsigned long)self.dataArray.count];
    CGFloat getWidth = 40;//[DocumentHelper getSizeWithStr:self.pageLabel.text Height:self.pagH Font:18].width+20;
    [self.pageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-(Bottom_H+kBottomSafeHeight));
        make.width.mas_equalTo(getWidth);
        make.height.mas_equalTo(self.pagH);
    }];
    self.pageLabel.hidden = NO;
}

#pragma mark -- lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //滚动方向
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
         
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = RGB(240, 240, 240);
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollEnabled = YES;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [_collectionView registerClass:[ShowPicCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ShowPicCollectionViewCell class])];
    }
    return _collectionView;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, kScreenHeight- Bottom_H - kBottomSafeHeight-30-30, 100, 30)];
        _pageLabel.backgroundColor = RGBA(76, 134, 255, 0.7);
        _pageLabel.font = PingFang_R_FONT_(13);
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.textColor = kWhiteColor;
        _pageLabel.clipsToBounds = YES;
        _pageLabel.layer.cornerRadius = 12;
    }
    return _pageLabel;
}

@end
