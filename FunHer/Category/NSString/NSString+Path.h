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

#pragma mark -- 目录
///  临时文档的图片路径
/// - Parameter idx: 索引
+ (NSString *)imagePathAtTempDocWithIndex:(NSInteger)idx;
/// 图片名
+ (NSString *)imageName;
/// 存储缩率图
+ (NSString *)thumbDir;

/// 存储展示图片
+ (NSString *)sampleDir;

/// 存储源图片
+ (NSString *)originalDir;

/// -- 临时文档
+ (NSString *)tempDocPath;

/// 存储图片的根目录
+ (NSString *)imageBox;

///  存储用户数据的根目录
+ (NSString *)appBox;

/// 确认目录存在
/// - Parameter path: 路径
+ (BOOL)verifyExistsAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
