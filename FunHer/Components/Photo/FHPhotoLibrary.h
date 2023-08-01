//
//  FHPhotoLibrary.h
//  FunHer
//
//  Created by GLA on 2023/8/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHPhotoLibrary : NSObject

/// 弹出系统相册选择照片 -- 选完图片立马dismiss
/// @param maxCount  最多可以选择图片 <=0 为无限多
/// @param sender 必须有值 当前调用相册的控制器
/// @param completion  选择照片回调，回调解析好的图片、对应的asset对象、是否原图
+ (void)configPhotoPickerWithMaxImagesCount:(NSInteger)maxCount sender:(UIViewController *)sender
                    selectedImageCompletion:(void (^ _Nullable)(NSArray<UIImage *> *images, NSArray<PHAsset *> *assets, BOOL isOriginal))completion;

/// 弹出系统相册选择照片 - 选完图片不会dismiss
/// @param maxCount  最多可以选择图片 <=0 为无限多
/// @param sender 必须有值 当前调用相册的控制器
/// @param completion  选择照片回调，回调解析好的图片、对应的asset对象、是否原图
+ (void)configPhotoPickerDismissWithMaxImagesCount:(NSInteger)maxCount sender:(UIViewController *)sender
                    selectedImageCompletion:(void (^ _Nullable)(NSArray<UIImage *> *images, NSArray<PHAsset *> *assets, BOOL isOriginal,UIViewController * _Nonnull selecter))completion;

/// 获取图片源数据 data
/// @param asset 图片资源
/// @param completion  回调
+ (void)fetchOriginalImageDataWithAsset:(PHAsset *)asset
                             completion:(void (^ _Nullable)(NSData *data, NSDictionary *info))completion;

/// 获取图片源数据 data 同步返回
/// @param asset 图片资源
+ (NSData *)syncFetchOriginalImageDataWithAsset:(PHAsset *)asset;

@end

NS_ASSUME_NONNULL_END
