//
//  FHFilterImageVC.m
//  FunHer
//
//  Created by GLA on 2023/8/18.
//

#import "FHFilterImageVC.h"
#import "FHFilterImagePresent.h"
#import "PhotoEditScrollView.h"
#import "FHCollectionAdapter.h"
#import "FHFilterCollectionCell.h"
#import "FHFilterCellModel.h"
#import "ImageTitleButton.h"

@interface FHFilterImageVC ()
@property (nonatomic, strong) FHFilterImagePresent *present;
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic ,strong) PhotoEditScrollView *showImgView;
@property (nonatomic, strong) UIView *bottomFunctionView;
@property (nonatomic, strong) ImageTitleButton *rotateBtn;
@property (nonatomic, strong) UIButton *completedBtn;
@property (nonatomic, strong) UICollectionView *filterShowcase;
@property (nonatomic, strong) FHCollectionAdapter *collectionAdapter;
@property (nonatomic, strong) UIImageView *showAnimationView;

@end

@implementation FHFilterImageVC

#pragma mark -- life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getEventWithName:NSStringFromClass([self class])];
    [self configNavBar];
    [self configContentView];
    [self configData];
}


#pragma mark -- Delegate
- (void)collectionViewDidSelected:(NSIndexPath *)idxPath withModel:(FHFilterCellModel *)model {
    [self getEventWithName:[NSString stringWithFormat:@"collectionViewDidSelected_%@",@(idxPath.item)]];
    [LZDispatchManager globalQueueHandler:^{
        [self.present didSelected:idxPath.item];
    } withMainCompleted:^{
        self.showImgView.mainImage = [UIImage imageWithContentsOfFile:self.present.filterImage];
        [self.collectionAdapter addDataArray:self.present.dataArray];
        [self.filterShowcase reloadData];
    }];
}

#pragma mark -- event response
#pragma mark -- 旋转图片
- (void)clickRotateBtn {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    [LZDispatchManager globalQueueHandler:^{
        [self.present rotateImageByRight];
    } withMainCompleted:^{
        self.showImgView.mainImage = [UIImage imageWithContentsOfFile:self.present.filterImage];
    }];
}

#pragma mark -- 渲染图片完成 --》生成新图片
- (void)clickCompletedBtn {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    if (self.objId) {
        [self.present refreshImage];
    } else {
        [self.present createDocWithImage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- public methods


#pragma mark -- private methods
#pragma mark -- 渲染图片过程动画
- (void)filterImageAnimationCompletion:(void (^)(void))completion {
    UIImage *mainImg = self.showAnimationView.image;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize mainViewSize = self.showImgView.mainImageView.frame.size;
    if (mainViewSize.width > self.showAnimationView.image.size.width || mainViewSize.height > self.showAnimationView.image.size.height) {
        if (completion) {
            completion();
        }
        return;
    }
    UIImage *showImg = [UIImage shrinkImageWithData:[UIImage saveImageForData:mainImg] withSize:CGSizeMake(mainViewSize.width/scale, mainViewSize.height/scale)];
    self.showAnimationView.image = showImg;
    [self.showImgView.mainImageView addSubview:self.showAnimationView];
    self.showAnimationView.frame = CGRectMake(0, 0, mainViewSize.width, 0);
    [UIView animateWithDuration:1.2 animations:^{
        CGRect rect2 = self.showAnimationView.frame;
        rect2.size.height += mainViewSize.height;
        self.showAnimationView.frame = rect2;
    } completion:^(BOOL finished) {
        self.showImgView.mainImage = mainImg;
        self.showAnimationView.alpha = 0.0;
        [self.showAnimationView removeFromSuperview];
        self.showAnimationView = nil;
        if (completion) {
            completion();
        }
    }];
}

- (void)configData {
    [LZFileManager removeItemAtPath:[NSString tempFilterDir]];
    [LZDispatchManager globalQueueHandler:^{
        [self.present refreshData];
    } withMainCompleted:^{
        self.showAnimationView.image = [UIImage imageWithContentsOfFile:self.present.filterImage];
        [self filterImageAnimationCompletion:^{}];
        [self.collectionAdapter addDataArray:self.present.dataArray];
        [self.filterShowcase reloadData];
    }];
}

- (void)configNavBar {
    self.title = @"Filter";
}

- (void)configContentView {
    self.view.backgroundColor = kWhiteColor;
    [self.view addSubview:self.superContentView];
    [self.superContentView addSubview:self.showImgView];
    [self.superContentView addSubview:self.bottomFunctionView];
    [self.bottomFunctionView addSubview:self.rotateBtn];
    [self.bottomFunctionView addSubview:self.completedBtn];
    [self.superContentView addSubview:self.filterShowcase];
    
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-kBottomSafeHeight);
    }];
    [self.showImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.superContentView);
        make.bottom.equalTo(self.superContentView).offset(-140);
    }];
    [self.bottomFunctionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(self.superContentView);
        make.height.mas_equalTo(50);
    }];
    [self.rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomFunctionView);
        make.leading.equalTo(self.bottomFunctionView).offset(15);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
    [self.completedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomFunctionView);
        make.trailing.equalTo(self.bottomFunctionView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(60, 36));
    }];
    [self.filterShowcase mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.superContentView);
        make.top.equalTo(self.showImgView.mas_bottom).offset(0);
        make.bottom.equalTo(self.bottomFunctionView.mas_top).offset(0);
    }];
    [self.showImgView layoutIfNeeded];
    
    UIImage *cropImg = [UIImage imageWithContentsOfFile:self.cropImgPath];
    self.showImgView.mainImage = cropImg;

}

#pragma mark -- getter and setters
- (FHFilterImagePresent *)present {
    if (!_present) {
        _present = [[FHFilterImagePresent alloc] init];
        _present.fileObjId = _objId;
        _present.fileName = _fileName;
        _present.cropImgPath = _cropImgPath;
        _present.selectdIndex = 2;
    }
    return _present;
}

- (UIView *)superContentView {
    if (!_superContentView) {
        UIView *content = [[UIView alloc] init];
        content.backgroundColor = kViewBGColor;
        _superContentView = content;
    }
    return _superContentView;
}

- (PhotoEditScrollView *)showImgView{
    if (!_showImgView) {
        _showImgView = [[PhotoEditScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavAndTabHeight-100)];
        _showImgView.userInteractionEnabled = YES;
        _showImgView.backgroundColor = kViewBGColor;
    }
    return _showImgView;
}

- (UIView *)bottomFunctionView {
    if (!_bottomFunctionView) {
        UIView *content = [[UIView alloc] init];
        content.backgroundColor = kWhiteColor;
        _bottomFunctionView = content;
    }
    return _bottomFunctionView;
}

- (ImageTitleButton *)rotateBtn {
    if (!_rotateBtn) {
        ImageTitleButton *ovalBtn = [[ImageTitleButton alloc] initWithStyle:EImageTopTitleBottom];
        [ovalBtn setImage:[UIImage imageNamed:@"rotate_btn"] forState:UIControlStateNormal];
        [ovalBtn setTitle:@"Rotate" forState:UIControlStateNormal];
        [ovalBtn.titleLabel setFont:PingFang_R_FONT_(11)];
        [ovalBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [ovalBtn setTitleColor:RGB(177, 177, 177) forState:UIControlStateNormal];
        [ovalBtn addTarget:self action:@selector(clickRotateBtn) forControlEvents:UIControlEventTouchUpInside];
        _rotateBtn = ovalBtn;
    }
    return _rotateBtn;
}

- (UIButton *)completedBtn {
    if (!_completedBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ovalBtn setImage:[UIImage imageNamed:@"done_btn"] forState:UIControlStateNormal];
        [ovalBtn setBackgroundColor:kThemeColor];
        [ovalBtn addTarget:self action:@selector(clickCompletedBtn) forControlEvents:UIControlEventTouchUpInside];
        ovalBtn.layer.cornerRadius = 4;
        _completedBtn = ovalBtn;
    }
    return _completedBtn;
}

- (FHCollectionAdapter *)collectionAdapter {
    __weak typeof(self) weakSelf = self;
    if (!_collectionAdapter) {
        FHCollectionAdapter *adapter = [[FHCollectionAdapter alloc] initWithIdentifier:NSStringFromClass([FHFilterCollectionCell class]) configureBlock:^(FHFilterCollectionCell *cell, FHFilterCellModel *model, NSIndexPath * _Nonnull indexPath) {
            cell.showImg.image = [UIImage imageWithContentsOfFile:model.image];
            cell.titleLab.text = model.title;
            cell.titleLab.backgroundColor = model.isSelect ? kThemeColor : RGBA(51, 51, 51, 0.3);
        } didSelectedBlock:^(FHFilterCellModel *model, NSIndexPath * _Nonnull indexPath) {
            [weakSelf collectionViewDidSelected:indexPath withModel:model];
        }];
        _collectionAdapter = adapter;
    }
    return _collectionAdapter;
}


- (UICollectionView *)filterShowcase {
    if (!_filterShowcase) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(80, 90);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        colView.backgroundColor = UIColor.clearColor;
        [colView registerClass:[FHFilterCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHFilterCollectionCell class])];
        colView.dataSource = self.collectionAdapter;
        colView.delegate = self.collectionAdapter;
        _filterShowcase = colView;
    }
    return _filterShowcase;
}

- (UIImageView *)showAnimationView{
    if (!_showAnimationView) {
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.contentMode = UIViewContentModeTop;
        imgV.clipsToBounds = YES;
        _showAnimationView = imgV;
    }
    return _showAnimationView;
}

- (void)dealloc {
    DELog(@"%s", __func__);
}

@end

