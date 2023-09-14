//
//  FHCameraVC.m
//  FunHer
//
//  Created by GLA on 2023/9/6.
//

#import "FHCameraVC.h"
#import "FHCameraCaptureView.h"

@interface FHCameraVC ()
@property (nonatomic, strong) FHCameraCaptureView *cameraView;
@property (nonatomic, strong) UIView *preView;
@property (nonatomic, strong) UIImageView *captureImageView;
@property (nonatomic, strong) UIButton *takePhotoBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation FHCameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configContentView];
    [LZFileManager removeItemAtPath:[NSString tempDocPath]];
}

#pragma mark -- life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupCaptureCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cameraView sessionStop];
}

#pragma mark -- event response
- (void)clickCancelBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickTakePhoto {
    [SVProgressHUD show];
    [self disableTakeBtn];
    [self.cameraView takePhoto];
    __weak typeof(self) weakSelf = self;
    self.cameraView.takePhotoBlock = ^(NSData * _Nonnull photoImage) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf ableTakeBtn];
        [SVProgressHUD dismiss];
        if (photoImage) {
            strongSelf.captureImageView.image = [UIImage imageWithData:photoImage];
            [strongSelf getImageCompleted:photoImage];
        }
    };
}

- (void)getImageCompleted:(NSData *)photo {
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.getPhotoBlock) {
        self.getPhotoBlock(photo);
    }
}

#pragma mark -- public methods
- (void)disableTakeBtn {
    self.takePhotoBtn.enabled = NO;
    [self.takePhotoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)ableTakeBtn {
    self.takePhotoBtn.enabled = YES;
    [self.takePhotoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

#pragma mark -- private methods
- (void)setupCaptureCamera {
    [self.cameraView setupCaptureCamera];
}

- (void)configContentView {
    self.view.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.cameraView];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.takePhotoBtn];
    [self.view addSubview:self.captureImageView];
    self.cameraView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.cameraView configContentView];
    
    self.cancelBtn.frame = CGRectMake(20, self.view.frame.size.height - 60, 60, 60);
    self.takePhotoBtn.frame = CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height - 60, 60, 60);
    self.captureImageView.frame = CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 60, 60, 60);
}

#pragma mark -- lazy
- (FHCameraCaptureView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[FHCameraCaptureView alloc] init];
    }
    return _cameraView;
}

- (UIView *)preView {
    if (!_preView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.blackColor;
        _preView = view;
    }
    return _preView;
}

- (UIImageView *)captureImageView {
    if (!_captureImageView) {
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        _captureImageView = imgV;
    }
    return _captureImageView;
}

- (UIButton *)takePhotoBtn {
    if (!_takePhotoBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ovalBtn setTitle:@"Take" forState:UIControlStateNormal];
        ovalBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        ovalBtn.titleLabel.textAlignment = NSTextAlignmentNatural;
        [ovalBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        [ovalBtn addTarget:self action:@selector(clickTakePhoto) forControlEvents:UIControlEventTouchUpInside];
        _takePhotoBtn = ovalBtn;
    }
    return _takePhotoBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ovalBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        ovalBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        ovalBtn.titleLabel.textAlignment = NSTextAlignmentNatural;
        [ovalBtn setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
        [ovalBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn = ovalBtn;
    }
    return _cancelBtn;
}

@end
