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

/// 刷新数据
- (void)refreshImage:(UIImage *)img;

- (NSString *)originalCropImagePath;

- (UIImage *)thumImageForCropWithSize:(CGSize)cropSize;

/// 创建文档
/// - Parameter img: 图片
- (void)createDocWithImage:(UIImage *)img;

@end

NS_ASSUME_NONNULL_END
