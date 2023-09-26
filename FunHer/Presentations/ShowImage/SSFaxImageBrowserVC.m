//
//  SSFaxImageBrowserVC.m
//  SimpleScan
//
//  Created by GLA on 2021/12/14.
//  Copyright © 2021 admin3. All rights reserved.
//

#import "SSFaxImageBrowserVC.h"
#import "SSImageBrowser.h"
#import "FHImageCellModel.h"
#import "FHCropImageVC.h"
#import "FHFileModel.h"

@interface SSFaxImageBrowserVC ()
@property (nonatomic, strong) SSImageBrowser *imageBrowser;
@property (nonatomic, strong) FHImageCellModel *currentModel;//当前图片数据模型

@end

@implementation SSFaxImageBrowserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getEventWithName:NSStringFromClass([self class])];
    [self configNavBar];
    [self configContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = RGB(240, 240, 240);
    [self loadBinData];
}

- (void)loadBinData {
    self.currentModel = self.dataArray[self.currentIndex];
    self.fileName = self.currentModel.fileName;
    self.title = self.fileName;
    self.imageBrowser.dataArray = self.dataArray;
    self.imageBrowser.currentIndex = self.currentIndex;
    [self.imageBrowser updateCurrentItem];
}

- (void)backHomeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickCropImage {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    FHCropImageVC *cropVC = [[FHCropImageVC alloc] init];
    cropVC.objId = self.currentModel.fileObj.objId;
    UINavigationController *nav = [[UINavigationController  alloc] initWithRootViewController:cropVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- 设置导航栏
- (void)configNavBar {
//    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self setRigthButton:@"Crop" withSelector:@selector(clickCropImage)];
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

- (void)configContentView {
    self.view.backgroundColor = RGB(240, 240, 240);
    [self.view addSubview:self.imageBrowser];
    [self.imageBrowser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-kBottomSafeHeight);
    }];
    __weak typeof(self) weakSelf = self;
    self.imageBrowser.refreshCurrentIndex = ^(NSInteger index) {
        weakSelf.currentIndex = index;
    };
}

#pragma mark -- lazy
- (SSImageBrowser *)imageBrowser {
    if (!_imageBrowser) {
        _imageBrowser = [[SSImageBrowser alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight, kScreenWidth, kScreenHeight - kNavBarAndStatusBarHeight - 49 - kBottomSafeHeight)];
    }
    return _imageBrowser;
}

- (void)dealloc {
    DELog(@"%s", __func__);
}

@end
