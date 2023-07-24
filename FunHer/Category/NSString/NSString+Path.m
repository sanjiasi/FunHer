//
//  NSString+Path.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "NSString+Path.h"

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

@end
