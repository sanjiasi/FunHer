//
//  FHCameraCaptureView.m
//  FunHer
//
//  Created by GLA on 2023/9/6.
//

#import "FHCameraCaptureView.h"
#import <AVFoundation/AVFoundation.h>

@interface FHCameraCaptureView ()<UIGestureRecognizerDelegate,AVCapturePhotoCaptureDelegate> {
    CGFloat _effectiveScale;
    CGFloat _beginGestureScale;
}

/** 捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入） */
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
/** 代表输入设备，使用AVCaptureDevice初始化 */
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput;
/** 由他将输入输出结合在一起，并开始启动捕获设备（摄像头） */
@property (nonatomic, strong) AVCaptureSession *captureSession;
/** 输出图片  */
@property (nonatomic, strong) AVCapturePhotoOutput *stillImageOutput;
/** 图像预览层，实时显示捕获的图像 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) UIView *preView;//预览视图
@property (nonatomic, strong) UIView *focusView;//聚焦视图

@end

@implementation FHCameraCaptureView

#pragma mark -- life cycle
- (instancetype)init {
    if (self = [super init]) {
        _effectiveScale = 1.0;
        _beginGestureScale = 1.0;
    }
    return self;
}

#pragma mark -- Delegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    NSData *imageData = [photo fileDataRepresentation];
    if (imageData) {
        if (self.takePhotoBlock) {
            self.takePhotoBlock(imageData);
        }
    }
}

#pragma mark -- event response
- (void)takePhoto {
    //拍照时的闪动效果
    CABasicAnimation *twinkleAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    twinkleAnim.fromValue = @(1);
    twinkleAnim.toValue = @(0);
    twinkleAnim.duration = 0.2;
    [self.layer addAnimation:twinkleAnim forKey:nil];
    
    //轻震动反馈
    [self impactFeedbackLight];
    
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecTypeJPEG}];
    [self.stillImageOutput capturePhotoWithSettings:settings delegate:self];
}

- (void)impactFeedbackLight {
    UIImpactFeedbackGenerator * feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [feedbackGenerator impactOccurred];
}

- (void)sessionStop {
    [self.captureSession stopRunning];
}

- (void)sessionRun {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
    });
}

#pragma mark -- 聚焦框
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (CGPoint)_focusPointOfInterestForTouchPoint:(CGPoint)touchPoint {
    return [self.videoPreviewLayer captureDevicePointOfInterestForPoint:touchPoint];
}

- (void)focusAtPoint:(CGPoint)point {
    CGPoint focusPoint = [self _focusPointOfInterestForTouchPoint:point];
    [self _focusAtPointOfInterest:focusPoint];
    [self setFocusAnimtionWithPoint:point];
}

- (BOOL)_focusAtPointOfInterest:(CGPoint)pointOfInterest {
    if ([self.captureDevice lockForConfiguration:nil]) {
        if (self.captureDevice.focusPointOfInterestSupported) {
            self.captureDevice.focusPointOfInterest = pointOfInterest;
        }
        if (self.captureDevice.exposurePointOfInterestSupported) {
            self.captureDevice.exposurePointOfInterest = pointOfInterest;
        }
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            self.captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            self.captureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        [self.captureDevice unlockForConfiguration];
        return YES;
    }
    return NO;
}

- (void)setFocusAnimtionWithPoint:(CGPoint)point {
    self.focusView.center = point;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.focusView.hidden = YES;
        }];
    }];
}

#pragma mark --缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:recognizer.view];
        CGPoint convertedLocation = [self.videoPreviewLayer convertPoint:location
                                                                 fromLayer:self.layer];
        if ( ! [self.videoPreviewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        _effectiveScale = _beginGestureScale * recognizer.scale;
        _effectiveScale = MAX(_effectiveScale, 1.0);
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        if (_effectiveScale > maxScaleAndCropFactor)
            _effectiveScale = maxScaleAndCropFactor;
        [self changeEffectiveScale];
    }
}

- (void)changeEffectiveScale {
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [self.videoPreviewLayer setAffineTransform:CGAffineTransformMakeScale(_effectiveScale, _effectiveScale)];
    [CATransaction commit];

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
}

#pragma mark -- private methods
- (void)setupCaptureCamera {
    self.stillImageOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.captureSession canAddInput:self.captureInput] && [self.captureSession canAddOutput:self.stillImageOutput]) {
        [self.captureSession addInput:self.captureInput];
        [self.captureSession addOutput:self.stillImageOutput];
        [self setupLivePreview];
    }
}

- (void)setupLivePreview {
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    if (self.videoPreviewLayer) {
        self.videoPreviewLayer.frame = self.preView.bounds;
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [self.preView.layer addSublayer:self.videoPreviewLayer];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)configContentView {
    self.backgroundColor = UIColor.blackColor;
    [self addSubview:self.preView];
    [self addSubview:self.focusView];
    //聚焦手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    
    //缩放手势
    UIPinchGestureRecognizer *pich = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pich];
    
    self.preView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark -- lazy
- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        session.sessionPreset = AVCaptureSessionPresetPhoto;//设置获取图片的大小
        _captureSession = session;
    }
    return _captureSession;
}

- (AVCaptureDeviceInput *)captureInput {
    if (!_captureInput) {
        NSError *error;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
        _captureInput = input;
    }
    return _captureInput;
}

- (AVCaptureDevice *)captureDevice {
    if (!_captureDevice) {
        AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _captureDevice = backCamera;
    }
    return _captureDevice;
}

- (UIView *)preView {
    if (!_preView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.blackColor;
        _preView = view;
    }
    return _preView;
}

- (UIView *)focusView {
    if (!_focusView) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        view.layer.borderWidth = 1.0;
        view.layer.borderColor =[UIColor whiteColor].CGColor;
        view.backgroundColor = [UIColor clearColor];
        view.hidden = YES;
        _focusView = view;
    }
    return _focusView;
}

@end
