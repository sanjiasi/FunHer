//
//  FHCameraCaptureView.h
//  FunHer
//
//  Created by GLA on 2023/9/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCameraCaptureView : UIView
@property (nonatomic, copy) void(^takePhotoBlock)(NSData *photoImage);

- (void)configContentView;

- (void)setupCaptureCamera;

- (void)takePhoto;

- (void)sessionStop;

- (void)sessionRun;

@end

NS_ASSUME_NONNULL_END
