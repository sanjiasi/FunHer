//
//  FHFilterImagePresent.m
//  FunHer
//
//  Created by GLA on 2023/8/24.
//

#import "FHFilterImagePresent.h"
#import "FHFilterCellModel.h"
#import "UIImage+Filter.h"
#import "UIImage+Orientation.h"
#import "FHReadFileSession.h"
#import "FHFileDataSession.h"
#import "UIImage+ZLPhotoBrowser.h"

//滤镜模式
typedef NS_ENUM(NSUInteger, FilterType) {
    FilterTypeOriginal = 0, //Original
    FilterTypeMagicColor,   //MagicColor
    FilterTypeNoShadow,     //NoShadow
    FilterTypeBW,           //B&W
    FilterTypeGrayscale,    //Grayscale
    FilterTypeNostalgic,    //Nostalgic
};

@interface FHFilterImagePresent ()
@property (nonatomic, copy) NSArray *filterArray;
@property (nonatomic, strong) NSMutableDictionary *filterResultDic;//记录滤镜处理过的图片

@end

@implementation FHFilterImagePresent

- (void)refreshData {
    NSMutableArray *dataSource = @[].mutableCopy;
    [self.filterArray enumerateObjectsUsingBlock:^(NSNumber *type, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = self.filterDic[[NSString stringWithFormat:@"%@",type]];
        NSData *imgData = [NSData dataWithContentsOfFile:self.cropImgPath];
        NSString *filePath = [NSString tempCropImagePath:name];
        UIImage *smallImg = [UIImage shrinkImageWithData:imgData withSize:CGSizeMake(80, 90)];
        UIImage *resultImg = [self filterImage:smallImg withType:[type integerValue]];
        [UIImage saveImage:resultImg atPath:filePath];
        FHFilterCellModel *model = [[FHFilterCellModel alloc] init];
        model.image = filePath;
        model.title = [name fileNameNOSuffix];
        model.isSelect = idx == self.selectdIndex ? YES : NO;
        [dataSource addObject:model];
    }];
    self.dataArray = [dataSource mutableCopy];
    [self updateFileImage];
    [UIImage clearGPUCache];
}

- (void)updateFileImage {
    FilterType type = [self.filterArray[self.selectdIndex] integerValue];
    NSString *filterKey = [NSString stringWithFormat:@"%@",@(type)];
    NSString *imgPath = self.filterResultDic[filterKey];
    if ([LZFileManager isExistsAtPath:imgPath]) {
        self.filterImage = imgPath;
    } else {
        UIImage *result = [self filterImage:[UIImage imageWithContentsOfFile:self.cropImgPath] withType:type];
        if (result) {
            NSString *filterImgPath = [NSString tempFilterImagePath:[NSString stringWithFormat:@"%@.jpg",filterKey]];
            [UIImage saveImage:result atPath:filterImgPath];
            self.filterResultDic[filterKey] = filterImgPath;
            self.filterImage = filterImgPath;
        }
    }
}

- (UIImage *)filterImage:(UIImage *)img withType:(FilterType)type {
    UIImage *result = img;
    switch (type) {
        case FilterTypeOriginal:
            result = img;
            break;
        case FilterTypeMagicColor:
            result = [UIImage filterByMagicColorImage:img];
            break;
        case FilterTypeNoShadow:
            result = [UIImage filterByNoShadowImage:img];
            break;
        case FilterTypeBW:
            result = [UIImage filterByBWImage:img];
            break;
        case FilterTypeGrayscale:
            result = [UIImage filterByGrayscaleImage:img];
            break;
        case FilterTypeNostalgic:
            result = [UIImage filterByNostalgicImage:img];
            break;
            
        default:
            break;
    }
    return result;
}

- (void)rotateImageByRight {
    UIImage *originalImg = [UIImage imageWithContentsOfFile:self.cropImgPath];
    UIImage *newImg = [originalImg changeRotate:UIImageOrientationRight];
    [UIImage saveImage:newImg atPath:self.cropImgPath];
    FilterType type = [self.filterArray[self.selectdIndex] integerValue];
    NSString *filterKey = [NSString stringWithFormat:@"%@",@(type)];

    [self.filterResultDic.allKeys enumerateObjectsUsingBlock:^(NSString *objKey, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = self.filterResultDic[objKey];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image) {
            UIImage *resultImg = [image changeRotate:UIImageOrientationRight];
            [UIImage saveImage:resultImg atPath:path];
            self.filterResultDic[objKey] = path;
            if ([objKey isEqualToString:filterKey]) {
                self.filterImage = path;
            }
        }
    }];
}

- (void)didSelected:(NSInteger)indx {
    if (self.selectdIndex == indx) return;
    self.selectdIndex = indx;
    [self.dataArray enumerateObjectsUsingBlock:^(FHFilterCellModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelect = indx == idx ? YES : NO;
    }];
    [self updateFileImage];
//    [UIImage clearGPUCache];
}

#pragma mark -- lazy
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

- (NSMutableDictionary *)filterResultDic {
    if (!_filterResultDic) {
        _filterResultDic = @{}.mutableCopy;
    }
    return _filterResultDic;
}


- (NSArray *)filterArray {
    return @[@(FilterTypeOriginal), @(FilterTypeMagicColor), @(FilterTypeNoShadow), @(FilterTypeBW), @(FilterTypeGrayscale), @(FilterTypeNostalgic), ];
}

- (NSDictionary *)filterDic {
    return @{
        [NSString stringWithFormat:@"%@",@(FilterTypeOriginal)]: @"Original.jpg",
        [NSString stringWithFormat:@"%@",@(FilterTypeMagicColor)]: @"MagicColor.jpg",
        [NSString stringWithFormat:@"%@",@(FilterTypeNoShadow)]: @"Noshadow.jpg",
        [NSString stringWithFormat:@"%@",@(FilterTypeBW)]: @"Blackwhite.jpg",
        [NSString stringWithFormat:@"%@",@(FilterTypeGrayscale)]: @"Gray.jpg",
        [NSString stringWithFormat:@"%@",@(FilterTypeNostalgic)]: @"Nostalgic.jpg"};
}

- (NSString *)parentId {
    NSDictionary *imgDic = [FHReadFileSession imageDicWithId:self.fileObjId];
    _parentId = imgDic[@"parentId"];
    return _parentId;
}

@end
