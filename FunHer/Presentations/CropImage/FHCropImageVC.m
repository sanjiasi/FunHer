//
//  FHCropImageVC.m
//  FunHer
//
//  Created by GLA on 2023/8/17.
//

#import "FHCropImageVC.h"
#import "Funher-Swift.h"
#import "FHMagnifierView.h"
#import "FHReadFileSession.h"
#import "FHCropImagePresent.h"
#import "FHFilterImageVC.h"
#import "FHNotificationManager.h"

CGFloat const CropView_Y = 45;
CGFloat const  CropView_X = 15;
CGFloat const kCameraToolsViewHeight = 60;

@interface FHCropImageVC ()<CropViewDelegate>
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic ,strong) CropView * cropView;
@property (nonatomic ,strong) FHMagnifierView *magnifierView;
@property (nonatomic, strong) FHCropImagePresent *present;
@property (nonatomic, strong) UIButton *actionBtn;//执行

@end

@implementation FHCropImageVC

#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getEventWithName:NSStringFromClass([self class])];
    [self configNavBar];
    [self configContentView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configData];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_magnifierView) {
        self.magnifierView.hidden = YES;
    }
}

#pragma mark -- Delegate
#pragma mark -- CropViewDelegate
- (void)panChangePoint:(CGPoint)point{
    //设置放大镜位置
    [self magnifierPosition:point];
    //显示放大镜
    self.magnifierView.hidden = NO;
}

- (void)panChangePointEnd{
    self.magnifierView.hidden = YES;
}

-(void)magnifierPosition:(CGPoint )position
{
    CGPoint sendPoint = position;//CGPointMake(position.x+CropView_X, position.y+kNavBarAndStatusBarHeight+CropView_Y);
    self.magnifierView.pointTomagnify = sendPoint;
}

#pragma mark -- event response
#pragma mark -- 裁剪图片完成
- (void)cropImageDone {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    UIImage *imageOne =  [self.cropView cropAndTransform];
    DELog(@"done -- %@",NSStringFromCGSize(imageOne.size));
    NSString *cropImagePath = [self.present saveCropImage:imageOne];
    if ([LZFileManager isExistsAtPath:cropImagePath]) {
        FHFilterImageVC *filerVC = [[FHFilterImageVC alloc] init];
        filerVC.objId = self.objId;
        filerVC.fileName = self.fileName;
        filerVC.cropImgPath = cropImagePath;
        [self.navigationController pushViewController:filerVC animated:YES];
    } else {
        DELog(@"done -- No crop image");
    }
}
#pragma mark -- public methods
- (void)clickCancel {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    [FHNotificationManager removeNotiOberver:self forName:FHAddImageByDocNotification];
    [LZFileManager removeItemAtPath:[NSString imageTempBox]];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- private methods
- (void)configNavBar {
    [self setLeftButton:@"Cancel" withSelector:@selector(clickCancel)];
//    [self setRigthButton:@"Done" withSelector:@selector(cropImageDone)];
}

- (void)setLeftButton:(nullable NSString *)title withSelector:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [btn setTitle:title forState:UIControlStateNormal];
//    [btn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"close_navItem"] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}


- (void)setRigthButton:(nullable NSString *)title withSelector:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 66, 44)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)configContentView {
    self.view.backgroundColor = kWhiteColor;
    [self.view addSubview:self.superContentView];
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(-kBottomSafeHeight);
    }];
    [self.superContentView addSubview:self.cropView];
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = kWhiteColor;
    [self.superContentView addSubview:bottomView];
    [bottomView addSubview:self.actionBtn];
    
    [self.cropView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.superContentView).offset(CropView_X);
        make.trailing.equalTo(self.superContentView).offset(-CropView_X);
        make.top.equalTo(self.superContentView).offset(CropView_Y);
        make.bottom.equalTo(self.superContentView).offset(-kCameraToolsViewHeight - CropView_Y);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.superContentView);
        make.height.mas_equalTo(70);
    }];
    
    [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(bottomView).offset(-15);
        make.centerY.equalTo(bottomView);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [self.superContentView.superview layoutIfNeeded];
}

- (void)configData {
    [LZFileManager removeItemAtPath:[NSString tempCropDir]];
    self.present.fileName = self.fileName;
    self.present.fileObjId = self.objId;
    UIImage *thumbImg = [self.present thumImageForCropWithSize:self.cropView.frame.size];
    if (thumbImg) {
        NSString *imgPath = [self.present originalCropImagePath];
        self.cropView.originalImage = [UIImage imageWithContentsOfFile:imgPath];
        [self.cropView setUpImageWithImage:thumbImg isAutomatic:YES];
    } else {
        [[FHToast shareInstance] makeToast:@"No Image"];
    }
}

#pragma mark -- getter and setters
- (UIView *)superContentView {
    if (!_superContentView) {
        UIView *content = [[UIView alloc] init];
        content.backgroundColor = kViewBGColor;
        _superContentView = content;
    }
    return _superContentView;
}

- (CropView*)cropView {
    if (!_cropView) {
        _cropView = [[CropView alloc] init];
        _cropView.cropViewDelegate = self;
    }
    return _cropView;
}

-(FHMagnifierView *)magnifierView {
    if (! _magnifierView) {
        _magnifierView = [[FHMagnifierView alloc]init];
        _magnifierView.magnifyView = self.cropView;
    }
    return _magnifierView;
}


- (FHCropImagePresent *)present {
    if (!_present) {
        _present = [[FHCropImagePresent alloc] init];
    }
    return _present;
}

- (UIButton *)actionBtn {
    if (!_actionBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"done_btn"] forState:UIControlStateNormal];
        [btn setBackgroundColor:kThemeColor];
        [btn addTarget:self action:@selector(cropImageDone) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        _actionBtn = btn;
    }
    return _actionBtn;
}

- (void)dealloc {
    DELog(@"%s", __func__);
}

@end
