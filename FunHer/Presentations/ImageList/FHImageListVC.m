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
#import "FHCropImageVC.h"
#import "FHNotificationManager.h"

@interface FHImageListVC ()
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FHImageListPresent *present;
@property (nonatomic, strong) FHCollectionAdapter *collectionAdapter;
@property (nonatomic, strong) UIButton *libraryBtn;

@end

@implementation FHImageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getEventWithName:NSStringFromClass([self class])];
    self.present.fileObjId = self.fileObjId;
    self.title = self.fileName;
    self.view.backgroundColor = kWhiteColor;
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
    [self getEventWithName:NSStringFromSelector(_cmd)];
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
        if (imagePaths.count == 1) {
            NSString *path = imagePaths[0];
            [strongSelf handleCropImage:path.fileName];
            return;
        }
        [strongSelf refreshWithNewData];
    }];
}

#pragma mark -- 跳转去裁剪图片
- (void)handleCropImage:(NSString *)fileName {
    FHCropImageVC *cropVC = [[FHCropImageVC alloc] init];
    cropVC.fileName = fileName;
    UINavigationController *nav = [[UINavigationController  alloc] initWithRootViewController:cropVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:NO completion:nil];
    [FHNotificationManager removeNotiOberver:self forName:FHAddImageByDocNotification];
    [FHNotificationManager addNotiOberver:self forName:FHAddImageByDocNotification selector:@selector(addImageAndRefresh:)];
}

#pragma mark -- public methods
- (void)refreshWithNewData {
    [LZDispatchManager globalQueueHandler:^{
        [self configData];
    } withMainCompleted:^{
        [self.collectionView reloadData];
    }];
}

#pragma mark -- 增加图片并刷新
- (void)addImageAndRefresh:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    [LZDispatchManager globalQueueHandler:^{
        [self.present createImage:userInfo];
        [self configData];
    } withMainCompleted:^{
        [self.collectionView reloadData];
    }];
    [FHNotificationManager removeNotiOberver:self forName:FHAddImageByDocNotification];
}

#pragma mark -- private methods
- (void)configNavBar {
//    [self setRigthButton:@"Add" withSelector:@selector(addPhotoFromLibrary)];
}

- (void)configContentView {
    self.view.backgroundColor = kViewBGColor;
    [self.view addSubview:self.superContentView];
    [self.superContentView addSubview:self.collectionView];
    [self.superContentView addSubview:self.libraryBtn];
    
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(-kBottomSafeHeight);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.trailing.equalTo(self.superContentView);
    }];
    
    [self.libraryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.superContentView).offset(-25);
        make.bottom.equalTo(self.superContentView).offset(-60);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    self.collectionView.dataSource = self.collectionAdapter;
    self.collectionView.delegate = self.collectionAdapter;
    
//    [self configPullRefreshing];
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
    [btn setTitleColor:kTextBlackColor forState:UIControlStateNormal];
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
        colView.backgroundColor = kViewBGColor;
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

- (UIButton *)libraryBtn {
    if (!_libraryBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"input_photo"] forState:UIControlStateNormal];
        [btn setBackgroundColor:kWhiteColor];
        btn.layer.cornerRadius = 30;
        [btn setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addPhotoFromLibrary) forControlEvents:UIControlEventTouchUpInside];
        _libraryBtn = btn;
    }
    return _libraryBtn;
}

- (void)dealloc {
    DELog(@"%s", __func__);
}

@end
