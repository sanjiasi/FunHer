//
//  FHFileChildListPresent.m
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import "FHFileChildListPresent.h"
#import "FHFileCellModel.h"
#import "FHReadFileSession.h"
#import "FHFileModel.h"
#import "FHFileDataSession.h"

@implementation FHFileChildListPresent

#pragma mark -- public methods
#pragma mark -- 新建文件夹
- (void)createFolderWithName:(NSString *)name {
    [FHFileDataSession addFolder:name atParent:self.fileObjId];
}

#pragma mark -- 新建文档
- (void)createDocWithImages:(NSArray *)imgs {
//    NSDictionary *doc = [FHFileDataSession addDocument:[NSDate timeFormatYMMDD:[NSDate date]] withParentId:self.fileObjId];
//    [imgs enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *thumbName = [NSString nameByRemoveIndex:name];
//        [FHFileDataSession addImage:thumbName byIndex:idx withParentId:doc[@"Id"]];
//    }];
    NSDictionary *doc = [FHFileDataSession addDocument:[NSDate timeFormatYMMDD:[NSDate date]] withParentId:self.fileObjId];
    [imgs enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *imgPath = [NSString tempImagePath:name];
        NSString *imgName = [NSString nameByRemoveIndex:name];
        NSString *originalPath = [NSString originalImagePath:imgName];
        [LZFileManager copyItemAtPath:imgPath toPath:originalPath overwrite:YES];
        [self saveSampleImage:[UIImage imageWithContentsOfFile:originalPath] withName:imgName];
        [FHFileDataSession addImage:imgName byIndex:idx withParentId:doc[@"Id"]];
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
            [self createDocWithImages:array];
            [self refreshData];
        }
        if (completion) {
            completion(array);
        }
    }];
}

- (void)refreshData {
    [self loadData];
}

- (void)saveOriginalPhoto:(NSData *)data imageSize:(CGSize)size atIndex:(NSUInteger)idx {
    NSString *imgPath = [NSString imagePathAtTempDocWithIndex:idx];
    BOOL result =[UIImage resizeOriginalImage:data imageSize:size saveAtPath:imgPath];
    if (!result) {
        [self getEventWithName:@"write error"];
        [LZFileManager copyItemAtPath:[NSString getLocalPlaceHolderFile] toPath:imgPath overwrite:YES];
    }
}

#pragma mark -- private methods
- (void)loadData {
    NSMutableArray *temp = @[].mutableCopy;
    NSArray *homeFolderList = [FHReadFileSession entityListToDic:[FHReadFileSession foldersByParentId:self.fileObjId]];
    NSArray *homeDocList = [FHReadFileSession entityListToDic:[FHReadFileSession documentsByParentId:self.fileObjId]];
    NSMutableArray *dataArr = [NSMutableArray arrayWithArray:homeFolderList];
    [dataArr addObjectsFromArray:homeDocList];
    [dataArr enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL * _Nonnull stop) {
        FHFileCellModel *model = [FHFileCellModel createModelWithParam:object];
        if ([model.fileObj.type isEqualToString:@"1"]) {//文件夹
            model.thumbNail = @"";//没有图片
        } else if ([model.fileObj.type isEqualToString:@"2"]) {//文档
            NSDictionary *firstImg = [FHReadFileSession firstImageDicByDoc:model.fileObj.objId];
            if (firstImg) {
                model.thumbNail = [[NSString thumbDir] stringByAppendingPathComponent:firstImg[@"name"]];
            } else {
                model.thumbNail = [[NSString thumbDir] stringByAppendingPathComponent:@"placeHolder.jpg"];
            }
            if (![LZFileManager isExistsAtPath:model.thumbNail]) {
                [LZFileManager copyItemAtPath:[NSString getLocalPlaceHolderFile] toPath:model.thumbNail overwrite:YES];
            }
        }
        [temp addObject:model];
    }];
    self.dataArray = temp;
}

#pragma mark -- getter and setters
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

@end
