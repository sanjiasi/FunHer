//
//  FHEditedCollectionView.m
//  FunHer
//
//  Created by GLA on 2023/9/8.
//

#import "FHEditedCollectionView.h"
#import "FHSystemActionManager.h"
#import "FHFileEditCellModel.h"
#import "FHFileModel.h"
#import "FHFileEditCollectionCell.h"
#import <Foundation/Foundation.h>

@interface FHEditedCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation FHEditedCollectionView

#pragma mark -- life cycle
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        //        _lastPosY = 0;
        self.backgroundColor = UIColor.whiteColor;//[UIColor viewControllerBackGroundColor:KAppDarkBackgroundColor defaultColor:KAppBackgroundColor];
        self.dataSource = self;
        self.delegate = self;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = YES;
        self.alwaysBounceVertical = YES;
//        [self configContentView];
        [self registerClass:[FHFileEditCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHFileEditCollectionCell class])];
        
        //        [self registerClass:[DocumentHeadReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentHeaderIdentifier];
        //        [self registerClass:[DocumentFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:DocumentFooterIdentifier];
        //        [self registerClass:[DocSectionOneHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DocumentOneHeaderIdentifier];
        
    }
    return self;
}


#pragma mark ** Delegate
#pragma mark -- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FHFileEditCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHFileEditCollectionCell class]) forIndexPath:indexPath];
    FHFileEditCellModel *model = self.dataArray[indexPath.item];
    cell.cellModel = model;
    return cell;
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.dataArray.count) return;
    FHFileEditCellModel *cellModel = self.dataArray[indexPath.item];
    if ([cellModel.fileObj.type isEqualToString:@"1"]) return;//文件夹不可编辑
    cellModel.isSelected = !cellModel.isSelected;
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    if (self.didSelectedBlock) {
        self.didSelectedBlock(indexPath);
    }
}

#pragma mark -- event response
#pragma mark -- 长按手势识别
- (void)longGestureRecognizer:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            //震动反馈
            [FHSystemActionManager impactFeedback];
            //手势开始
            //判断手势落点位置是否在row上
            NSIndexPath *indexPath = [self indexPathForItemAtPoint:[longPress locationInView:self]];
            if (indexPath == nil) break;
            if (self.didSelectedBlock) {
                self.didSelectedBlock(indexPath);
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            //iOS9 方法 移动过程中随时更新cell位置
        }
            break;
        case UIGestureRecognizerStateEnded: {
            //手势结束
        }
            break;
        default:
            break;
    }
}

#pragma mark -- public methods
- (void)setListArray:(NSMutableArray *)listArray {
    
}

#pragma mark -- private methods
//- (void)addLongGesture {
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognizer:)];
//    [self addGestureRecognizer:longPress];
//}
//
//- (void)configContentView {
//    [self addLongGesture];
//}

#pragma mark -- getter and setters
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

@end
