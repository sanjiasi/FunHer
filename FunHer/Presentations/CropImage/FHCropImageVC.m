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

CGFloat const CropView_Y = 45;
CGFloat const  CropView_X = 15;
CGFloat const kCameraToolsViewHeight = 60;

@interface FHCropImageVC ()<CropViewDelegate>
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic ,strong) CropView * cropView;
@property (nonatomic ,strong) FHMagnifierView *magnifierView;
@property (nonatomic, strong) FHCropImagePresent *present;

@end

@implementation FHCropImageVC

#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavBar];
    [self configContentView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self configData];
    });
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
    UIImage *imageOne =  [self.cropView cropAndTransform];
    NSLog(@"done -- %@",NSStringFromCGSize(imageOne.size));
    NSString *cropImagePath = [self.present saveCropImage:imageOne];
    if ([LZFileManager isExistsAtPath:cropImagePath]) {
        FHFilterImageVC *filerVC = [[FHFilterImageVC alloc] init];
        filerVC.objId = self.objId;
        filerVC.fileName = self.fileName;
        filerVC.cropImgPath = cropImagePath;
        [self.navigationController pushViewController:filerVC animated:YES];
    } else {
        NSLog(@"done -- No crop image");
    }
//    [self.present createDocWithImage:imageOne];
//    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- public methods


#pragma mark -- private methods
- (void)configNavBar {
    [self setRigthButton:@"Done" withSelector:@selector(cropImageDone)];
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

- (void)configContentView {
    [self.view addSubview:self.superContentView];
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
    }];
    [self.superContentView addSubview:self.cropView];
    
    [self.cropView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.superContentView).offset(CropView_X);
        make.trailing.equalTo(self.superContentView).offset(-CropView_X);
        make.top.equalTo(self.superContentView).offset(CropView_Y);
        make.bottom.equalTo(self.superContentView).offset(-kCameraToolsViewHeight - CropView_Y);
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
    if (!_cropView) {//WithFrame:CGRectMake(CropView_X, CropView_Y , kScreenWidth-30, ((kScreenHeight - kCameraToolsViewHeight-kNavBarAndStatusBarHeight-kBottomSafeHeight)*(kScreenWidth-30))/kScreenWidth)
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

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
