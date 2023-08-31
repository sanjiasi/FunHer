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
#import "UIViewController+Alert.h"
#import "FHFileChildListVC.h"
#import "FHFileModel.h"
#import "FHImageListVC.h"
#import "FHCollectionMenu.h"
#import "FHCropImageVC.h"
#import "FHNotificationManager.h"

@interface FHFileListVC () {
    CGFloat FHMenuHeight;
}
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FHFileListPresent *present;
@property (nonatomic, strong) FHCollectionAdapter *collectionAdapter;
@property (nonatomic, weak) UIViewController *photoSender;
@property (nonatomic, strong) FHCollectionMenu *funcMenu;

@end

@implementation FHFileListVC

#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Files";
    self.view.backgroundColor = UIColor.whiteColor;
    [self configNavBar];
    [self configContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setTranslucent:NO];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self refreshWithNewData];
}

//    [LZDBService clearRealmDB];
//    [LZFileManager removeItemAtPath:[NSString imageBox]];

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
    [FHPhotoLibrary configPhotoPickerWithMaxImagesCount:0 sender:self selectedImageCompletion:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        [self handleAssets:assets];
    }];
}

#pragma mark -- 新建文件夹
- (void)addNewFolder {
    __weak typeof(self) weakSelf = self;
    [self takeAlertWithTitle:@"Create new folder" placeHolder:@"New Folder" actionBlock:^(NSString * _Nonnull fieldText) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf handleCreateFolder:fieldText];
    } cancelBlock:^{
        NSLog(@"cancel");
    }];
}

- (void)handleCreateFolder:(NSString *)name {
    [LZDispatchManager globalQueueHandler:^{
        [self.present createFolderWithName:name];
        [self refreshWithNewData];
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

- (void)handleCropImage:(NSString *)fileName {
    FHCropImageVC *cropVC = [[FHCropImageVC alloc] init];
    cropVC.fileName = fileName;
    [self.navigationController pushViewController:cropVC animated:YES];
    [FHNotificationManager addNotiOberver:self forName:FHCreateDocNotification selector:@selector(addDocAndRefresh:)];
}

#pragma mark -- public methods
- (void)refreshWithNewData {
    [LZDispatchManager globalQueueHandler:^{
        [self configData];
    } withMainCompleted:^{
//        [self endPullRefreshing];
        [self.collectionView reloadData];
    }];
}

#pragma mark -- 增加文档并刷新
- (void)addDocAndRefresh:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    [LZDispatchManager globalQueueHandler:^{
        [self.present createDocWithImage:userInfo];
        [self configData];
    } withMainCompleted:^{
        [self.collectionView reloadData];
    }];
}

#pragma mark -- private methods
- (void)configNavBar {
    [self setRigthButton:@"Add" withSelector:@selector(addPhotoFromLibrary)];
}

- (void)configContentView {
    FHMenuHeight = 80;
    [self.view addSubview:self.superContentView];
    [self.superContentView addSubview:self.collectionView];
    [self.superContentView addSubview:self.funcMenu];
    
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(-kBottomSafeHeight);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(self.superContentView);
        make.top.equalTo(self.funcMenu.mas_bottom).offset(10);
    }];
    
    [self.funcMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.superContentView).offset(10);
        make.leading.trailing.equalTo(self.superContentView);
        make.height.mas_equalTo(FHMenuHeight);
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
    if ([self.collectionView.mj_header isRefreshing]) {
        [self.collectionView.mj_header endRefreshing];
    }
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
        content.backgroundColor = kViewBGColor;
        _superContentView = content;
    }
    return _superContentView;
}
    
- (FHCollectionMenu *)funcMenu {
    __weak typeof(self) weakSelf = self;
    if (!_funcMenu) {
        _funcMenu = [[FHCollectionMenu alloc] initWithItems:[self funcItems] menuHeight:FHMenuHeight actionBlock:^(NSInteger idx, NSString * _Nonnull selector) {
            NSLog(@"i = %@, func = %@", @(idx), selector);
            [weakSelf invokeWithSelector:selector];
        }];
    }
    return _funcMenu;
}

- (NSArray *)funcItems {
    return @[@{@"image": @"input_doc", @"title": @"Import Files", @"selector": @"addPhotoFromLibrary"},
             @{@"image": @"input_phtoto", @"title": @"Import Images", @"selector": @"addPhotoFromLibrary"},
             @{@"image": @"add_folder", @"title": @"CreateFolders", @"selector": @"addNewFolder"},
    ];
}

@end
