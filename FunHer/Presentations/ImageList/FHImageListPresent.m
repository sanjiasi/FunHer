//
//  FHImageListPresent.m
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import "FHImageListPresent.h"
#import "FHImageCellModel.h"
#import "FHReadFileSession.h"
#import "FHFileModel.h"
#import "FHFileDataSession.h"

@implementation FHImageListPresent

#pragma mark -- public methods
#pragma mark -- 批量解析图片
- (void)anialysisAssets:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion {
    [LZFileManager removeItemAtPath:[NSString tempDocPath]];
    dispatch_group_t groupE = dispatch_group_create();
    
    [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [LZDispatchManager asyncConcurrentByGroup:groupE withHandler:^{
            NSData *data = [FHPhotoLibrary syncFetchOriginalImageDataWithAsset:asset];
            [self saveOriginalPhoto:data imageSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) atIndex:idx];
        }];
    }];
    [LZDispatchManager groupTask:groupE withCompleted:^{
        NSArray *array = [NSString sortPicArrayAtPath:[NSString tempDocPath]];
        if (array.count > 1) {
            [self addImages:array];
            [self refreshData];
        }
        if (completion) {
            completion(array);
        }
    }];
}

- (void)addImages:(NSArray *)imgs {
    NSInteger start = [FHReadFileSession lastImageIndexByParentId:self.fileObjId] + 1;
    [imgs enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *imgPath = [NSString tempImagePath:name];
        NSString *imgName = [NSString nameByRemoveIndex:name];
        NSString *originalPath = [NSString originalImagePath:imgName];
        [LZFileManager copyItemAtPath:imgPath toPath:originalPath overwrite:YES];
        [self saveSampleImage:[UIImage imageWithContentsOfFile:originalPath] withName:imgName];
        NSInteger picIndex = idx + start;
        [FHFileDataSession addImage:imgName byIndex:picIndex withParentId:self.fileObjId];
    }];
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

#pragma mark -- 新建图片
- (NSDictionary *)createImage:(NSDictionary *)info {
    NSString *fileName = info[@"fileName"];//临时存放原图片名
    NSString *sampleImgPath = info[@"sampleImage"];//处理后的展示图
    NSString *originalName = [NSString nameByRemoveIndex:fileName];
    NSString *originalPath = [NSString originalImagePath:originalName];
    //保存原图
    [LZFileManager copyItemAtPath:[NSString tempImagePath:fileName] toPath:originalPath overwrite:YES];
    [self saveSampleImage:[UIImage imageWithContentsOfFile:sampleImgPath] withName:originalName];
    //新增图片数据
    NSInteger start = [FHReadFileSession lastImageIndexByParentId:self.fileObjId] + 1;
    NSDictionary *img = [FHFileDataSession addImage:originalName byIndex:start withParentId:self.fileObjId];
    [LZFileManager removeItemAtPath:[NSString imageTempBox]];//清空临时目录
    return img;
}


- (void)refreshData {
    [self loadData];
}


- (NSString *)saveOriginalPhoto:(NSData *)data imageSize:(CGSize)size atIndex:(NSUInteger)idx {
    NSString *imgPath = [NSString imagePathAtTempDocWithIndex:idx];
    BOOL result = [UIImage resizeOriginalImage:data imageSize:size saveAtPath:imgPath];
    if (!result) {
        [self getEventWithName:@"write error"];
        [LZFileManager copyItemAtPath:[NSString getLocalPlaceHolderFile] toPath:imgPath overwrite:YES];
    }
    return imgPath;
}

#pragma mark -- private methods
- (void)loadData {
    NSMutableArray *temp = @[].mutableCopy;
    NSArray *imgList = [FHReadFileSession entityListToDic:[FHReadFileSession sortImageRLMsByParentId:self.fileObjId]];
    [imgList enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL * _Nonnull stop) {
        FHImageCellModel *model = [self buildCellModelWihtObject:object atIndex:idx];
        if (model) {
            [temp addObject:model];
        }
    }];
    self.dataArray = temp;
}

- (FHImageCellModel *)buildCellModelWihtObject:(NSDictionary *)object atIndex:(NSUInteger)idx {
    FHImageCellModel *model = [FHImageCellModel createModelWithParam:object];
    if ([model.fileObj.type isEqualToString:@"3"]) {//图片
        model.thumbNail = [NSString thumbImagePath:model.fileObj.name];
        model.fileName = [NSString stringWithFormat:@"%@  %@",@(idx+1), model.fileSize];
        if (![LZFileManager isExistsAtPath:model.thumbNail]) {
            [LZFileManager copyItemAtPath:[NSString getLocalPlaceHolderFile] toPath:model.thumbNail overwrite:YES];
        }
    }
    return model;
}

#pragma mark -- getter and setters
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

@end
