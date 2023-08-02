//
//  FHFileListVC.m
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import "FHFileListVC.h"
#import "FHCollectionAdapter.h"
#import "FHFileCollectionCell.h"
#import "FHFileCellModel.h"
#import "FHFileListPresent.h"
#import "FHPhotoLibrary.h"
#import "LZDBService.h"

@interface FHFileListVC ()
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FHFileListPresent *present;
@property (nonatomic, strong) FHCollectionAdapter *collectionAdapter;
@property (nonatomic, weak) UIViewController *photoSender;


@end

@implementation FHFileListVC

#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Files";
    self.view.backgroundColor = UIColor.whiteColor;
//    [LZDBService clearRealmDB];
//    [LZFileManager removeItemAtPath:[NSString imageBox]];
    [self configNavBar];
    [self configContentView];
//    [self configData];
}




#pragma mark -- Delegate
- (void)collectionViewDidSelected:(NSIndexPath *)idxPath WithModel:(FHFileCellModel *)model {
    NSLog(@"selected -- %@", model.fileName);
}

#pragma mark -- event response
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
    [self configData];
    [self.collectionView reloadData];
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
    [self.collectionView.mj_header beginRefreshing];
}

- (void)configData {
    [self.collectionAdapter addDataArray:self.present.dataArray];
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
        FHCollectionAdapter *adapter = [[FHCollectionAdapter alloc] initWithIdentifier:NSStringFromClass([FHFileCollectionCell class]) configureBlock:^(FHFileCollectionCell *cell, FHFileCellModel *model, NSIndexPath * _Nonnull indexPath) {
            cell.showImg.image = [UIImage imageWithContentsOfFile:model.thumbNail];
            cell.titleLab.text = model.fileName;
            cell.numLab.text = model.countNum;
        } didSelectedBlock:^(FHFileCellModel *model, NSIndexPath * _Nonnull indexPath) {
            [weakSelf collectionViewDidSelected:indexPath WithModel:model];
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
        
        CGFloat xSpace = 5;
        CGFloat itemW = (width-xSpace*(columnCount+1))/columnCount;
        layout.itemSize = CGSizeMake(itemW, itemW);
        layout.minimumInteritemSpacing = xSpace;
        layout.minimumLineSpacing = xSpace;
        layout.sectionInset = UIEdgeInsetsMake(3, xSpace, 3, xSpace);
        
        
        UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        colView.backgroundColor = UIColor.whiteColor;
        [colView registerClass:[FHFileCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHFileCollectionCell class])];
        _collectionView = colView;
    }
    return _collectionView;
}

- (FHFileListPresent *)present {
    if (!_present) {
        _present = [[FHFileListPresent alloc] init];
    }
    return _present;
}

- (UIView *)superContentView {
    if (!_superContentView) {
        UIView *content = [[UIView alloc] init];
        content.backgroundColor = RGB(245, 240, 239);
        _superContentView = content;
    }
    return _superContentView;
}
    
@end
