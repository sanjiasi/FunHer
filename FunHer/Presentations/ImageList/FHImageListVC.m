//
//  FHImageListVC.m
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import "FHImageListVC.h"
#import "FHCollectionAdapter.h"
#import "FHImageCollectionCell.h"
#import "FHImageCellModel.h"
#import "FHImageListPresent.h"
#import "FHPhotoLibrary.h"
#import "FHFileModel.h"
#import "SSFaxImageBrowserVC.h"

@interface FHImageListVC ()
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FHImageListPresent *present;
@property (nonatomic, strong) FHCollectionAdapter *collectionAdapter;

@end

@implementation FHImageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.present.fileObjId = self.fileObjId;
    self.title = self.fileName;
    self.view.backgroundColor = UIColor.whiteColor;
    [self configNavBar];
    [self configContentView];
    [LZFileManager removeItemAtPath:[NSString imageTempBox]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshWithNewData];
}

#pragma mark -- Delegate
- (void)collectionViewDidSelected:(NSIndexPath *)idxPath withModel:(FHImageCellModel *)model {
    SSFaxImageBrowserVC *vc = [[SSFaxImageBrowserVC alloc] init];
    vc.dataArray = self.present.dataArray;
    vc.currentIndex = idxPath.item;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- event response
#pragma mark -- 查看大图

#pragma mark -- 打开相册找照片
- (void)addPhotoFromLibrary {
    [FHPhotoLibrary configPhotoPickerWithMaxImagesCount:0 sender:self selectedImageCompletion:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        [self handleAssets:assets];
    }];
}

#pragma mark -- 批量处理Assets
- (void)handleAssets:(NSArray *)assets {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    __weak typeof(self) weakSelf = self;
    [self.present anialysisAssets:assets completion:^(NSArray * _Nonnull imagePaths) {
        [SVProgressHUD dismiss];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshWithNewData];
    }];
}

#pragma mark -- public methods
- (void)refreshWithNewData {
    [LZDispatchManager globalQueueHandler:^{
        [self configData];
    } withMainCompleted:^{
        [self endPullRefreshing];
        [self.collectionView reloadData];
    }];
}

#pragma mark -- private methods
- (void)configNavBar {
    [self setRigthButton:@"Add" withSelector:@selector(addPhotoFromLibrary)];
}

- (void)configContentView {
    [self.view addSubview:self.superContentView];
    [self.superContentView addSubview:self.collectionView];
    
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.trailing.equalTo(self.superContentView);
    }];
    
    self.collectionView.dataSource = self.collectionAdapter;
    self.collectionView.delegate = self.collectionAdapter;
    
    [self configPullRefreshing];
}

/// -- 下拉刷新组件
- (void)configPullRefreshing {
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshWithNewData];
    }];
}

- (void)configData {
    [self.present refreshData];
    [self.collectionAdapter addDataArray:self.present.dataArray];
}

#pragma mark -- 开始下拉刷新
- (void)beginPullRefreshing {
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark -- 结束下拉刷新
- (void)endPullRefreshing {
    [self.collectionView.mj_header endRefreshing];
}

- (void)setRigthButton:(nullable NSString *)title withSelector:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 115;
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}


#pragma mark -- getter and setters
- (FHCollectionAdapter *)collectionAdapter {
    __weak typeof(self) weakSelf = self;
    if (!_collectionAdapter) {
        FHCollectionAdapter *adapter = [[FHCollectionAdapter alloc] initWithIdentifier:NSStringFromClass([FHImageCollectionCell class]) configureBlock:^(FHImageCollectionCell *cell, FHImageCellModel *model, NSIndexPath * _Nonnull indexPath) {
            cell.showImg.image = NULLString(model.thumbNail) ? [UIImage imageNamed:@"placeHolder"] : [UIImage imageWithContentsOfFile:model.thumbNail];
            cell.titleLab.text = model.fileName;
        } didSelectedBlock:^(FHImageCellModel *model, NSIndexPath * _Nonnull indexPath) {
            [weakSelf collectionViewDidSelected:indexPath withModel:model];
        }];
        _collectionAdapter = adapter;
    }
    return _collectionAdapter;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        CGFloat width = MIN(kScreenWidth, kScreenHeight);
        NSInteger columnCount = 2;
        
        CGFloat margin = 15;
        CGFloat padding = 10;
        CGFloat itemW = (width - padding*(columnCount-1) - margin*2)/columnCount;
        layout.itemSize = CGSizeMake(itemW, itemW * 1.4);//500,700
        layout.minimumInteritemSpacing = padding;
        layout.minimumLineSpacing = padding;
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
        
        
        UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        colView.backgroundColor = RGB(244, 244, 244);
        [colView registerClass:[FHImageCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHImageCollectionCell class])];
        _collectionView = colView;
    }
    return _collectionView;
}

- (FHImageListPresent *)present {
    if (!_present) {
        _present = [[FHImageListPresent alloc] init];
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

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
