//
//  NSString+Path.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "NSString+Path.h"
#import "LZFileManager.h"

@implementation NSString (Path)

#pragma mark -- 文件目录
- (NSString *)fileDirectory {
    NSString *path = (NSString *)self;
    return [path stringByDeletingLastPathComponent];
}

#pragma mark -- 文件名
- (NSString *)fileName {
    NSString *name = [self fileNameBySuffix:YES];
    return name;
}

#pragma mark -- 文件名-去掉后缀
- (NSString *)fileNameNOSuffix {
    NSString *name = [self fileNameBySuffix:NO];
    return name;
}

#pragma mark -- 文件后缀
- (NSString *)fileSuffix {
    NSString *path = (NSString *)self;
    return [path pathExtension];
}

- (NSString *)fileNameBySuffix:(BOOL)suffix {
    NSString *path = (NSString *)self;
    NSString *fileName = [path lastPathComponent];
    if (!suffix) {
        fileName = [fileName stringByDeletingPathExtension];
    }
    return fileName;
}

#pragma mark ** 目录
+ (NSString *)imagePathAtTempDocWithIndex:(NSInteger)idx {
    NSInteger num = idx + 1;
    NSString *imageName = [NSString stringWithFormat:@"%@%@",@(num), FHFilePathExtension];
    NSString *imgPath = [[self tempDocPath] stringByAppendingPathComponent:imageName];
    return imgPath;
}

+ (NSString *)imageName {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *uuidMD5 = [uuid md5Str];
    NSString *name = [NSString stringWithFormat:@"%@%@",uuidMD5, FHFilePathExtension];
    return name;
}

#pragma mark -- 存储缩率图
+ (NSString *)thumbDir {
    NSString *dir = [[self imageBox] stringByAppendingPathComponent:@"thumbs"];
    [self verifyExistsAtPath:dir];
    return dir;
}

#pragma mark -- 存储展示图片
+ (NSString *)sampleDir {
    NSString *dir = [[self imageBox] stringByAppendingPathComponent:@"samples"];
    [self verifyExistsAtPath:dir];
    return dir;
}

#pragma mark -- 存储源图片
+ (NSString *)originalDir {
    NSString *dir = [[self imageBox] stringByAppendingPathComponent:@"originals"];
    [self verifyExistsAtPath:dir];
    return dir;
}

#pragma mark -- 临时文档
+ (NSString *)tempDocPath {
    NSString *dir = [[self imageBox] stringByAppendingPathComponent:@"tempDoc"];
    [self verifyExistsAtPath:dir];
    return dir;
}

#pragma mark -- 存储图片的根目录
+ (NSString *)imageBox {
    NSString *box = [[self appBox] stringByAppendingPathComponent:@"Image_File"];
    [self verifyExistsAtPath:box];
    return box;
}

#pragma mark -- 存储用户数据的根目录
+ (NSString *)appBox {
    NSString *box = [[LZFileManager appSupportDir] stringByAppendingPathComponent:@"FunHerBox"];
    [self verifyExistsAtPath:box];
    return box;
}

#pragma mark -- 确认目录存在
+ (BOOL)verifyExistsAtPath:(NSString *)path {
    if (![LZFileManager isExistsAtPath:path]) {
        return [LZFileManager createDirectoryAtPath:path];
    }
    return YES;
}


@end
