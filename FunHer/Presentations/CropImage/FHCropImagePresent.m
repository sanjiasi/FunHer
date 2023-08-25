//
//  FHCropImagePresent.m
//  FunHer
//
//  Created by GLA on 2023/8/18.
//

#import "FHCropImagePresent.h"
#import "FHReadFileSession.h"
#import "FHFileDataSession.h"

@implementation FHCropImagePresent

- (void)refreshImage:(UIImage *)img {
    NSString *originalName = [self originalImageName];
    [self saveSampleImage:img withName:originalName];
    [FHFileDataSession updateImageWithId:self.fileObjId];
}

- (NSString *)saveCropImage:(UIImage *)img {
    if (img) {
        NSString *imageName = [self originalImageName];
        NSString *cropImgPath = [NSString tempCropImagePath:imageName];
        BOOL result = [UIImage saveImage:img atPath:cropImgPath];
        return result ? cropImgPath : @"";
    }
    return @"";
}

- (void)createDocWithImage:(UIImage *)img {
    if (img) {
        NSString *cropImgPath = [self saveCropImage:img];
        if (NULLString(cropImgPath)) {
            [LZFileManager copyItemAtPath:[NSString getLocalPlaceHolderFile] toPath:cropImgPath overwrite:YES];
            [self getEventWithName:@"write error"];
        }
        
        if (self.fileObjId) {
            [self refreshImage:img];
        } else if (self.fileName) {
            NSString *originalName = [self originalImageName];
            NSString *originalPath = [NSString originalImagePath:originalName];
            if (![LZFileManager isExistsAtPath:originalPath]) {
                [LZFileManager copyItemAtPath:[NSString tempImagePath:self.fileName] toPath:originalPath overwrite:YES];
            }
            [self saveSampleImage:img withName:originalName];
            NSDictionary *doc = [FHFileDataSession addDocument:[NSDate timeFormatYMMDD:[NSDate date]] withParentId:self.parentId];
            [FHFileDataSession addImage:originalName byIndex:0 withParentId:doc[@"Id"]];
        }
    }
}

- (void)saveSampleImage:(UIImage *)img withName:(NSString *)name {
    NSString *sampeImagePath = [NSString sampleImagePath:name];
    BOOL result = [UIImage saveImage:img atPath:sampeImagePath];
    if (result) {
        //保存图片并生成一张缩率图
        NSData *sampleData = [UIImage saveImageForData:img];
        [UIImage resizeThumbImage:sampleData imageSize:img.size saveAtPath:[NSString thumbImagePath:name]];
    } else {
        [LZFileManager copyItemAtPath:[NSString getLocalPlaceHolderFile] toPath:sampeImagePath overwrite:YES];
        [self getEventWithName:@"write error"];
    }
}

- (NSString *)originalImageName {
    if (self.fileObjId) {
        NSDictionary *img = [FHReadFileSession imageDicWithId:self.fileObjId];
        return img[@"name"];
    } else if (self.fileName) {//从相册选取图片
        return [NSString nameByRemoveIndex:self.fileName];
    }
    return @"";
}

- (NSString *)originalCropImagePath {
    NSString *imgPath;
    if (self.fileObjId) {
        NSDictionary *img = [FHReadFileSession imageDicWithId:self.fileObjId];
        NSString *imgName = img[@"name"];
        imgPath = [NSString originalImagePath:imgName];
    } else if (self.fileName) {//从相册选取图片
        imgPath = [NSString tempImagePath:self.fileName];
    }
    return imgPath;
}

- (UIImage *)thumImageForCropWithSize:(CGSize)cropSize {
    UIImage *thumbImg;
    NSString *imgPath = [self originalCropImagePath];
    if ([LZFileManager isExistsAtPath:imgPath]) {
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        thumbImg = [UIImage shrinkImageWithData:imgData withSize:cropSize];
    }
    return thumbImg;
}

@end
