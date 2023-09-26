//
//  FHFileChildListVC.m
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import "FHFileChildListVC.h"
#import "FHCollectionAdapter.h"
#import "FHFileCollectionCell.h"
#import "FHFileCellModel.h"
#import "FHFileChildListPresent.h"
#import "FHPhotoLibrary.h"
#import "FHFileModel.h"
#import "FHImageListVC.h"
#import "FHCropImageVC.h"
#import "FHNotificationManager.h"
#import "FHCameraVC.h"
#import "UICollectionView+LongPressGesture.h"
#import "FHEditItemsVC.h"
#import "ImageTitleButton.h"

@interface FHFileChildListVC ()
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FHFileChildListPresent *present;
@property (nonatomic, strong) FHCollectionAdapter *collectionAdapter;
@property (nonatomic, weak) UIViewController *photoSender;
@property (nonatomic, strong) ImageTitleButton *libraryBtn;
@property (nonatomic, strong) ImageTitleButton *cameraBtn;

@end

@implementation FHFileChildListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (void)collectionViewDidSelected:(NSIndexPath *)idxPath withModel:(FHFileCellModel *)model {
    if ([model.fileObj.type isEqualToString:@"1"]) {//文件夹
        [self goToPushFolderVC:model];
    } else if ([model.fileObj.type isEqualToString:@"2"]) {//文档
        [self goToPushDocVC:model];
    }
}

#pragma mark -- event response
#pragma mark -- 跳转文件夹界面
- (void)goToPushFolderVC:(FHFileCellModel *)model {
    if (NULLString(model.fileObj.objId)) {
        [self getEventWithName:@"no objId"];
        return;
    }
    FHFileChildListVC *childVC = [[FHFileChildListVC alloc] init];
    childVC.fileObjId = model.fileObj.objId;
    childVC.fileName = model.fileName;
    [self.navigationController pushViewController:childVC animated:YES];
}

#pragma mark -- 跳转文档界面
- (void)goToPushDocVC:(FHFileCellModel *)model {
    if (NULLString(model.fileObj.objId)) {
        [self getEventWithName:@"no objId"];
        return;
    }
    FHImageListVC *childVC = [[FHImageListVC alloc] init];
    childVC.fileObjId = model.fileObj.objId;
    childVC.fileName = model.fileName;
    [self.navigationController pushViewController:childVC animated:YES];
}

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
    [FHNotificationManager addNotiOberver:self forName:FHAddImageByDocNotification selector:@selector(addDocAndRefresh:)];
}

#pragma mark -- 打开相机拍照
- (void)takePhotoByCamera {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    FHCameraVC *cameraVC = [[FHCameraVC alloc] init];
    cameraVC.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self) weakSelf = self;
    cameraVC.getPhotoBlock = ^(NSData * _Nonnull photoImage) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf savePhotoToFilter:photoImage];
    };
    [self.navigationController presentViewController:cameraVC animated:YES completion:nil];
}

#pragma mark -- 拍照获取的照片去做滤镜处理
- (void)savePhotoToFilter:(NSData *)photoImage {
    UIImage *img = [UIImage imageWithData:photoImage];
    NSString *imgPath = [self.present saveOriginalPhoto:photoImage imageSize:img.size atIndex:0];
    [self handleCropImage:[imgPath fileName]];
}

#pragma mark -- 新建文件夹
- (void)addNewFolder {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    __weak typeof(self) weakSelf = self;
    [self takeAlertWithTitle:@"Create new folder" placeHolder:@"New Folder" actionBlock:^(NSString * _Nonnull fieldText) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf handleCreateFolder:fieldText];
    } cancelBlock:^{
        DELog(@"cancel");
    }];
}

- (void)handleCreateFolder:(NSString *)name {
    [LZDispatchManager globalQueueHandler:^{
        [self.present createFolderWithName:name];
        [self refreshWithNewData];
    }];
}

#pragma mark -- 选择文件
- (void)selectItemsAction {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    if (self.present.dataArray.count == 0) return;
    self.present.selectedIndex = nil;
    [self goToSelectedItems];
}

- (void)goToSelectedItems {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    FHEditItemsVC *vc = [[FHEditItemsVC alloc] init];
    vc.parentId = self.present.fileObjId;
    if (self.present.selectedIndex) {
        if (![self.present canSelectedToEdit]) {
            return;
        }
        vc.selectedIndex = self.present.selectedIndex;
        vc.selectedItem = self.present.selectedObjectId;
    }
    __weak typeof(self) weakSelf = self;
    vc.moveCopyToPathBlock = ^(NSString * _Nonnull objectId) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        FHFileCellModel *model = [strongSelf.present fileModelWithId:objectId];
        [strongSelf goToPushFolderVC:model];
    };
    vc.mergeToNewFileBlock = ^(NSString * _Nonnull objectId) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        FHFileCellModel *model = [strongSelf.present fileModelWithId:objectId];
        [strongSelf goToPushDocVC:model];
    };
    vc.deleteFileBlock = ^{
        // 刷新
    };
    vc.shareFileBlock = ^{
        // 暂无需要处理
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:NO completion:nil];
}

#pragma mark -- public methods
- (void)refreshWithNewData {
    [LZDispatchManager globalQueueHandler:^{
        [self configData];
    } withMainCompleted:^{
        [self.collectionView reloadData];
    }];
}

#pragma mark -- 增加文档并刷新
- (void)addDocAndRefresh:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    [LZDispatchManager globalQueueHandler:^{
        NSDictionary *newDoc = [self.present createDocWithImage:userInfo];
        FHFileCellModel *model = [self.present buildCellModelWihtObject:newDoc];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goToPushDocVC:model];
        });
    }];
    [FHNotificationManager removeNotiOberver:self forName:FHAddImageByDocNotification];
}

#pragma mark -- private methods
- (void)configNavBar {
    [self setRigthButton:@"Select" withSelector:@selector(selectItemsAction)];
}

- (void)configContentView {
    self.view.backgroundColor = kViewBGColor;
    [self.view addSubview:self.superContentView];
    [self.superContentView addSubview:self.collectionView];
    [self.superContentView addSubview:self.libraryBtn];
    [self.superContentView addSubview:self.cameraBtn];
    
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(-kBottomSafeHeight);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.superContentView);
        make.bottom.equalTo(self.libraryBtn.mas_top).offset(-10);
    }];
    
    [self.libraryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.superContentView).offset(25);
        make.trailing.equalTo(self.superContentView.mas_centerX).offset(-10);
        make.centerY.equalTo(self.cameraBtn.mas_centerY).offset(0);
        make.height.mas_equalTo(50);
    }];
    
    [self.cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.superContentView.mas_centerX).offset(10);
        make.trailing.equalTo(self.superContentView).offset(-25);
        make.bottom.equalTo(self.superContentView).offset(-25);
        make.height.mas_equalTo(50);
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
    [btn setImage:[UIImage imageNamed:@"edit_selected_all"] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}


#pragma mark -- getter and setters
- (FHCollectionAdapter *)collectionAdapter {
    __weak typeof(self) weakSelf = self;
    if (!_collectionAdapter) {
        FHCollectionAdapter *adapter = [[FHCollectionAdapter alloc] initWithIdentifier:NSStringFromClass([FHFileCollectionCell class]) configureBlock:^(FHFileCollectionCell *cell, FHFileCellModel *model, NSIndexPath * _Nonnull indexPath) {
            if ([model.fileObj.type isEqualToString:@"1"]) {
                cell.showImg.contentMode = UIViewContentModeCenter;
                cell.showImg.image = [UIImage imageNamed:@"new_folder"];
            } else {
                cell.showImg.contentMode = UIViewContentModeScaleAspectFill;
                cell.showImg.image = [UIImage imageWithContentsOfFile:model.thumbNail];
            }
            cell.titleLab.text = model.fileName;
            cell.numLab.text = model.countNum;
            cell.uTimeLab.text = model.uDate;
        } didSelectedBlock:^(FHFileCellModel *model, NSIndexPath * _Nonnull indexPath) {
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
        NSInteger columnCount = 3;
        
        CGFloat margin = 15;
        CGFloat padding = 10;
        CGFloat itemW = (width - padding*(columnCount-1) - margin*2)/columnCount;
        layout.itemSize = CGSizeMake(itemW, itemW * 1.4);
        layout.minimumInteritemSpacing = padding;
        layout.minimumLineSpacing = padding;
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
        
        
        UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        colView.backgroundColor = kViewBGColor;
        [colView registerClass:[FHFileCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHFileCollectionCell class])];
        __weak typeof(self) weakSelf = self;
        [colView addLongPressGestureWithDidSelected:^(NSIndexPath * _Nonnull indexPath) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.present.selectedIndex = indexPath;
            [strongSelf goToSelectedItems];
        }];
        _collectionView = colView;
    }
    return _collectionView;
}

- (FHFileChildListPresent *)present {
    if (!_present) {
        _present = [[FHFileChildListPresent alloc] init];
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

- (ImageTitleButton *)libraryBtn {
    if (!_libraryBtn) {
        ImageTitleButton *btn = [[ImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightCenter)];
        [btn setImage:[UIImage imageNamed:@"input_photo"] forState:UIControlStateNormal];
        [btn setTitle:@"Photo" forState:UIControlStateNormal];
        [btn setTitleColor:kTextBlackColor forState:UIControlStateNormal];
        [btn.titleLabel setFont:PingFang_M_FONT_(16)];
        [btn addTarget:self action:@selector(addPhotoFromLibrary) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 8;
        [btn setBackgroundColor:kWhiteColor];
        btn.padding = CGSizeMake(10, 0);
        _libraryBtn = btn;
    }
    return _libraryBtn;
}

- (ImageTitleButton *)cameraBtn {
    if (!_cameraBtn) {
        ImageTitleButton *btn = [[ImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightCenter)];
        [btn setImage:[UIImage imageNamed:@"take_camera"] forState:UIControlStateNormal];
        [btn setTitle:@"Camera" forState:UIControlStateNormal];
        [btn setTitleColor:kTextBlackColor forState:UIControlStateNormal];
        [btn.titleLabel setFont:PingFang_M_FONT_(16)];
        [btn addTarget:self action:@selector(takePhotoByCamera) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 8;
        [btn setBackgroundColor:kWhiteColor];
        btn.padding = CGSizeMake(10, 0);
        _cameraBtn = btn;
    }
    return _cameraBtn;
}

- (void)dealloc {
    DELog(@"%s", __func__);
}

@end
