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

@interface SSFaxImageBrowserVC ()
@property (nonatomic, strong) SSImageBrowser *imageBrowser;
@property (nonatomic, strong) FHImageCellModel *currentModel;//当前图片数据模型

@end

@implementation SSFaxImageBrowserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configNavBar];
    [self configContentView];
}

- (void)backHomeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = RGB(240, 240, 240);
    [self loadBinData];
}

- (void)loadBinData {
    self.imageBrowser.dataArray = self.dataArray;
    self.imageBrowser.currentIndex = self.currentIndex;
    [self.imageBrowser updateCurrentItem];
}

#pragma mark -- 设置导航栏
- (void)configNavBar {
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
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

@end
