//
//  FHCropImagePresent.h
//  FunHer
//
//  Created by GLA on 2023/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCropImagePresent : NSObject
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileObjId;//文件主键id
@property (nonatomic, copy) NSString *parentId;//上层目录文件id

- (NSString *)originalCropImagePath;

- (UIImage *)thumImageForCropWithSize:(CGSize)cropSize;

/// 保存裁剪后的图片
/// - Parameter img: 裁剪图
- (NSString *)saveCropImage:(UIImage *)img;

@end

NS_ASSUME_NONNULL_END
