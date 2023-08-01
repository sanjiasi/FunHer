//
//  FHPhotoLibrary.m
//  FunHer
//
//  Created by GLA on 2023/8/1.
//

#import "FHPhotoLibrary.h"
#import "ZLPhotoBrowser.h"

@implementation FHPhotoLibrary

+ (void)configPhotoPickerWithMaxImagesCount:(NSInteger)maxCount sender:(UIViewController *)sender selectedImageCompletion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<PHAsset *> * _Nonnull, BOOL))completion {
    ZLPhotoActionSheet *ac = [self defaultSheet];
    // 相册参数配置，configuration有默认值，可直接使用并对其属性进行修改
    ac.configuration.maxSelectCount = maxCount > 0 ? maxCount : NSIntegerMax;
    ac.configuration.isDismiss = YES;
    // 选择回调
    [ac setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        if (completion) {
            completion(images, assets, isOriginal);
        }
    }];
    // 直接调用相册
    [ac showPhotoLibraryWithSender:sender];
}

+ (void)configPhotoPickerDismissWithMaxImagesCount:(NSInteger)maxCount sender:(UIViewController *)sender selectedImageCompletion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<PHAsset *> * _Nonnull, BOOL, UIViewController * _Nonnull))completion{
    ZLPhotoActionSheet *ac = [self defaultSheet];
    // 相册参数配置，configuration有默认值，可直接使用并对其属性进行修改
    ac.configuration.maxSelectCount = maxCount > 0 ? maxCount : NSIntegerMax;
    ac.configuration.isDismiss = NO;
    // 选择回调
    [ac setSelectImageTempBlock:^(NSArray<UIImage *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal, UIViewController * _Nonnull selecter) {
        if (completion) {
            completion(images, assets, isOriginal, selecter);
        }
    }];
    // 直接调用相册
    [ac showPhotoLibraryWithSender:sender];
}

+ (ZLPhotoActionSheet *)defaultSheet {
    ZLPhotoActionSheet *ac = [[ZLPhotoActionSheet alloc] init];
    // 相册参数配置，configuration有默认值，可直接使用并对其属性进行修改
    ac.configuration.maxPreviewCount = 0;
    ac.configuration.allowSelectVideo = NO;
    ac.configuration.allowSelectGif = NO;
    ac.configuration.allowTakePhotoInLibrary = NO;
    ac.configuration.allowEditImage = NO;
    ac.configuration.allowEditImage = NO;
    ac.configuration.allowSelectOriginal = NO;
    ac.configuration.indexLabelBgColor = kThemeColor;
    ac.configuration.bottomBtnsNormalBgColor = kThemeColor;
    ac.configuration.bottomBtnsDisableBgColor = RGBA(31, 61, 115, 1.0);
    ac.configuration.shouldAnialysisAsset = NO;
    return ac;
}

+ (void)fetchOriginalImageDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData * _Nonnull, NSDictionary * _Nonnull))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
        if (completion) {
            completion(imageData, info);
        }
    }];
}

+ (NSData *)syncFetchOriginalImageDataWithAsset:(PHAsset *)asset {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    __block NSData *data;
    [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
        data = imageData;
        dispatch_semaphore_signal(semaphore);
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
    }];
    
    return data;
}

@end
