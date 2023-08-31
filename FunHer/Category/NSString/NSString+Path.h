//
//  NSString+Path.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Path)
/// -- 文件目录
- (NSString *)fileDirectory;

/// -- 文件名
- (NSString *)fileName;

/// -- 文件名-去掉后缀
- (NSString *)fileNameNOSuffix;

/// -- 文件后缀
- (NSString *)fileSuffix;

/// 去掉索引
/// - Parameter fileName: 图片名
+ (NSString *)nameByRemoveIndex:(NSString *)fileName;

/// 图片索引 排序
- (NSString *)fileIndex;

#pragma mark -- 目录
/// 占位图
+ (NSString *)getLocalPlaceHolderFile;

///  临时文档的图片路径
/// - Parameter idx: 索引
+ (NSString *)imagePathAtTempDocWithIndex:(NSInteger)idx;

/// 图片名
+ (NSString *)imageName;

/// 存储缩率图
+ (NSString *)thumbDir;
+ (NSString *)thumbImagePath:(NSString *)name;

/// 存储展示图片
+ (NSString *)sampleDir;
+ (NSString *)sampleImagePath:(NSString *)name;

/// 存储源图片
+ (NSString *)originalDir;
+ (NSString *)originalImagePath:(NSString *)name;

/// -- 临时文档
+ (NSString *)tempDocPath;
+ (NSString *)tempImagePath:(NSString *)name;

/// -- 临时存放裁剪后的图片
+ (NSString *)tempCropDir;
+ (NSString *)tempCropImagePath:(NSString *)name;

/// -- 临时存放渲染后的图片
+ (NSString *)tempFilterDir;
+ (NSString *)tempFilterImagePath:(NSString *)name;

/// 临时存储图片的根目录
+ (NSString *)imageTempBox;

/// 存储图片的根目录
+ (NSString *)imageBox;

/// 数据库根目录
+ (NSString *)dbBox;

///  存储用户数据的根目录
+ (NSString *)appBox;

/// 确认目录存在
/// - Parameter path: 路径
+ (BOOL)verifyExistsAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
