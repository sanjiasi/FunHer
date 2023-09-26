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
#import "FHCameraVC.h"
#import "UICollectionView+LongPressGesture.h"
#import "FHEditItemsVC.h"
#import "NSString+Device.h"

NSString *const FHTabCollectionHeaderIdentifier = @"TabbarCollectionHeaderIdentifier";

@interface FHFileListVC ()<UIDocumentPickerDelegate, MFMailComposeViewControllerDelegate> {
    CGFloat FHMenuHeight;
}

@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FHFileListPresent *present;
@property (nonatomic, strong) FHCollectionAdapter *collectionAdapter;
@property (nonatomic, weak) UIViewController *photoSender;
@property (nonatomic, strong) FHCollectionMenu *funcMenu;
@property (nonatomic, strong) UIButton *cameraBtn;

@end

@implementation FHFileListVC

#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getEventWithName:NSStringFromClass([self class])];
    self.title = @"Files";
    self.view.backgroundColor = kWhiteColor;
    [self configNavBar];
    [self configContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshWithNewData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? UIStatusBarStyleDarkContent : UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

#pragma mark -- Delegate
- (void)collectionViewDidSelected:(NSIndexPath *)idxPath withModel:(FHFileCellModel *)model {
    if ([model.fileObj.type isEqualToString:@"1"]) {//文件夹
        [self goToPushFolderVC:model];
    } else if ([model.fileObj.type isEqualToString:@"2"]) {//文档
        [self goToPushDocVC:model];
    }
}

#pragma mark -- UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSDictionary *newDoc = [self.present handlePickDocumentsAtURLs:urls];
    if (newDoc) {
        FHFileCellModel *model = [self.present buildCellModelWihtObject:newDoc];
        [self goToPushDocVC:model];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark -- 打开文件(app)找图片
- (void)addPhotoFromFiles {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    NSArray *documentTypes = @[@"public.image",@"com.adobe.pdf"];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
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
    vc.parentId = FHParentIdByHome;
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

#pragma mark -- 反馈
- (void)sendEmialFeedback {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        return;
    }
    if (![mailClass canSendMail]) {
        [self takeAlert:@"Email Account Setup" withMessage:@"You haven't set your email account, Please go to your phone “Setting-Email”,tap “Add Account” to create your email account" actionHandler:^{
        }];
        return;
    }
    
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    mailCompose.mailComposeDelegate = self;
    //主题
    [mailCompose setSubject:@"Light Scanner Feedback"];
    //收件人
    NSArray *toRecipients = [NSArray arrayWithObjects:@"guarenzhi@gmail.com",nil];
    [mailCompose setToRecipients:toRecipients];
    
    NSString *emailBody = [NSString stringWithFormat:@"Model:%@\n %@\n App:%@",[NSString deviceVersion],[NSString systemVersion],[NSString appVersion]];
    [mailCompose setMessageBody:emailBody isHTML:NO];
    [self presentViewController:mailCompose animated:YES completion:^{}];
}

#pragma mark -- public methods
#pragma mark -- 刷新数据
- (void)refreshWithNewData {
    static BOOL first = YES;
    if (first) {
        first = NO;
        self.present.dataArray = [KAppDelegate.homeData mutableCopy];
        [self.collectionAdapter addDataArray:self.present.dataArray];
        [self.collectionView reloadData];
        return;
    }
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
#pragma mark -- 配置导航栏和子视图
- (void)configNavBar {
    [self setLeftButton:@"@US" withSelector:@selector(sendEmialFeedback)];
    [self setRigthButton:@"Select" withSelector:@selector(selectItemsAction)];
}

- (void)configContentView {
    FHMenuHeight = 80;
    self.view.backgroundColor = kViewBGColor;
    [self.view addSubview:self.superContentView];
    [self.superContentView addSubview:self.collectionView];
    [self.superContentView addSubview:self.cameraBtn];
    
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(-kBottomSafeHeight);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(self.superContentView);
        make.top.equalTo(self.superContentView).offset(10);
    }];
    [self.cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.superContentView).offset(-20);
        make.bottom.equalTo(self.superContentView).offset(-80);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    self.collectionView.dataSource = self.collectionAdapter;
    self.collectionView.delegate = self.collectionAdapter;

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

- (void)setLeftButton:(nullable NSString *)title withSelector:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kTextBlackColor forState:UIControlStateNormal];
    [btn.titleLabel setFont:PingFang_R_FONT_(13)];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
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
        adapter.headerIdentifier = FHTabCollectionHeaderIdentifier;
        adapter.headerConfigure = ^(UICollectionReusableView *reusableview, NSString * _Nonnull headerId, NSIndexPath * _Nonnull indexPath) {
            reusableview.backgroundColor = kViewBGColor;
            [reusableview addSubview:weakSelf.funcMenu];
            [weakSelf.funcMenu mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(reusableview).offset(0);
                make.leading.trailing.equalTo(reusableview);
                make.height.mas_equalTo(80);
            }];
        };
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
        layout.headerReferenceSize = CGSizeMake(kScreenWidth, FHMenuHeight + 0);
        
        UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        colView.backgroundColor = kViewBGColor;
        [colView registerClass:[FHFileCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHFileCollectionCell class])];
        [colView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:FHTabCollectionHeaderIdentifier];
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
        _funcMenu = [[FHCollectionMenu alloc] initWithItems:[self.present funcItems] menuHeight:FHMenuHeight actionBlock:^(NSInteger idx, NSString * _Nonnull selector) {
            DELog(@"i = %@, func = %@", @(idx), selector);
            [weakSelf invokeWithSelector:selector];
        }];
    }
    return _funcMenu;
}

- (UIButton *)cameraBtn {
    if (!_cameraBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ovalBtn setImage:[UIImage imageNamed:@"take_camera"] forState:UIControlStateNormal];
        [ovalBtn setBackgroundColor:kWhiteColor];
        [ovalBtn addTarget:self action:@selector(takePhotoByCamera) forControlEvents:UIControlEventTouchUpInside];
        ovalBtn.layer.cornerRadius = 30;
        _cameraBtn = ovalBtn;
    }
    return _cameraBtn;
}


@end
