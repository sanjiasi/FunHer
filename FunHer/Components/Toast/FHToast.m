//
//  FHToast.m
//  FunHer
//
//  Created by GLA on 2023/7/26.
//

#import "FHToast.h"
#import "GCDTimer.h"

@interface ToastTitle : UILabel
- (void)setToastText:(NSString *)text;

@end

@implementation ToastTitle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 9;
        self.layer.masksToBounds = YES;
        self.backgroundColor = RGBA(0, 0, 0, 0.6);
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = UIColor.systemBackgroundColor;
        self.font = PingFang_R_FONT_(15);
    }
    return self;
}

- (void)setToastText:(NSString *)text {
    [self setText:text];
    CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    CGFloat SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil];
    CGFloat width = rect.size.width + 36;
    CGFloat height = rect.size.height + 20;
    CGFloat x = (SCREEN_WIDTH-width)/2;
    CGFloat y = SCREEN_HEIGHT/2 - height;
    self.frame = CGRectMake(x, y, width, height);
}

@end

@interface FHToast () {
    GCDTimer countTimer;
}
@property (nonatomic, strong) ToastTitle *toastLab;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation FHToast

+ (instancetype)shareInstance {
    static FHToast *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[FHToast alloc] init];
    });
    return singleTon;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _toastLab = [[ToastTitle alloc] init];
    }
    return self;
}

#pragma makr -- 弹出toast
- (void)makeToast:(NSString *)message {// 1.0秒后toast自动消失
    [self makeToast:message duration:1.0];
}

//@param message  显示的文本内容 @param duration 显示时间
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration {
    if (![NSThread isMainThread]) {
        DELog(@"***********************(take on main thread)*****************");
        return;
    }

    if (NULLString(message)) {
        return;
    }
    [self hiddenToast];
    [self hiddenLoadingView];
    [self.toastLab setToastText:message];
    [self.maskView addSubview:self.toastLab];
    self.toastLab.alpha = 1.0;
    
    __weak typeof(self) weakSelf = self;
    countTimer = CreateGCDCountdownTimer(duration, ^{
        [weakSelf hiddenToast];
    });
}

- (void)setToastCenter:(CGPoint)center {
    self.toastLab.center = (center);
}

//totast消失
- (void)hiddenToast {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.toastLab.alpha == 1.0) {
            self.toastLab.alpha = 0;
            [self.toastLab removeFromSuperview];
            [self.maskView removeFromSuperview];
            self.maskView = nil;
        }
    });
}

#pragma mark -- 加载动画
- (void)makeLoading {
    if (![NSThread isMainThread]) {
        DELog(@"***********************(take on main thread)*****************");
        return;
    }
    
    [self.activityIndicator startAnimating];
    __weak typeof(self) weakSelf = self;
    countTimer = CreateGCDCountdownTimer(10, ^{
        [weakSelf hiddenLoadingView];
    });
}

- (void)hiddenLoadingView {
    if (_activityIndicator) {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        [self.maskView removeFromSuperview];
        self.activityIndicator = nil;
        self.maskView = nil;
    }
}

- (void)dealloc {
    countTimer = nil;
}

//遮罩层
- (UIView *)maskView {
    if (!_maskView) {
        UIView *mask = [[UIView alloc] init];
        mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.05];
        UIWindow *window = KAppWindow;
        [window addSubview:mask];
        mask.frame = window.bounds;
        mask.userInteractionEnabled = NO;
        _maskView = mask;
    }
    return _maskView;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
        CGFloat SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
        _activityIndicator.frame = CGRectMake(0, 0, 60, 60);
        _activityIndicator.layer.cornerRadius = 5;
        _activityIndicator.layer.masksToBounds = YES;
        _activityIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.maskView addSubview:_activityIndicator];
        _activityIndicator.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    }
    return _activityIndicator;
}


@end
