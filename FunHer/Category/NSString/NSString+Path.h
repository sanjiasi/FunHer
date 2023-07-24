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

@end

NS_ASSUME_NONNULL_END
