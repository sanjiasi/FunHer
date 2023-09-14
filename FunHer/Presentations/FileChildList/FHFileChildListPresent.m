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
- (NSDictionary *)createDocWithImage:(NSDictionary *)info {
    NSString *fileName = info[@"fileName"];//临时存放原图片名
    NSString *sampleImgPath = info[@"sampleImage"];//处理后的展示图
    NSString *originalName = [NSString nameByRemoveIndex:fileName];
    NSString *originalPath = [NSString originalImagePath:originalName];
    //保存原图
    [LZFileManager copyItemAtPath:[NSString tempImagePath:fileName] toPath:originalPath overwrite:YES];
    [self saveSampleImage:[UIImage imageWithContentsOfFile:sampleImgPath] withName:originalName];
    //新增文档数据
    NSDictionary *doc = [FHFileDataSession addDocument:[NSString defaultDocName] withParentId:self.fileObjId];
    //新增图片数据
    [FHFileDataSession addImage:originalName byIndex:0 withParentId:doc[@"Id"]];
    [LZFileManager removeItemAtPath:[NSString imageTempBox]];//清空临时目录
    return doc;
}

#pragma mark -- 新建文档
- (void)createDocWithImages:(NSArray *)imgs {
    NSString *docName = [NSString defaultDocName];
    [self createDoc:docName withImages:imgs];
}

- (NSDictionary *)createDoc:(NSString *)name withImages:(NSArray *)imgs {
    NSDictionary *doc = [FHFileDataSession addDocument:name withParentId:self.fileObjId];
    [imgs enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *imgPath = [NSString tempImagePath:name];
        NSString *imgName = [NSString nameByRemoveIndex:name];
        NSString *originalPath = [NSString originalImagePath:imgName];
        [LZFileManager copyItemAtPath:imgPath toPath:originalPath overwrite:YES];
        [self saveSampleImage:[UIImage imageWithContentsOfFile:originalPath] withName:imgName];
        [FHFileDataSession addImage:imgName byIndex:idx withParentId:doc[@"Id"]];
    }];
    return doc;
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

- (NSString *)saveOriginalPhoto:(NSData *)data imageSize:(CGSize)size atIndex:(NSUInteger)idx {
    NSString *imgPath = [NSString imagePathAtTempDocWithIndex:idx];
    BOOL result = [UIImage resizeOriginalImage:data imageSize:size saveAtPath:imgPath];
    if (!result) {
        [self getEventWithName:@"write error"];
        [LZFileManager copyItemAtPath:[NSString getLocalPlaceHolderFile] toPath:imgPath overwrite:YES];
    }
    return imgPath;
}

- (void)refreshData {
    [self loadData];
}


#pragma mark -- private methods
- (void)loadData {
    NSMutableArray *temp = @[].mutableCopy;
    NSArray *homeFolderList = [FHReadFileSession entityListToDic:[FHReadFileSession foldersByParentId:self.fileObjId]];
    NSArray *homeDocList = [FHReadFileSession entityListToDic:[FHReadFileSession documentsByParentId:self.fileObjId]];
    NSMutableArray *dataArr = [NSMutableArray arrayWithArray:homeFolderList];
    [dataArr addObjectsFromArray:homeDocList];
    [dataArr enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL * _Nonnull stop) {
        FHFileCellModel *model = [self buildCellModelWihtObject:object];
        if (model) {
            [temp addObject:model];
        }
    }];
    self.dataArray = temp;
}

- (FHFileCellModel *)buildCellModelWihtObject:(NSDictionary *)object {
    FHFileCellModel *model = [FHFileCellModel createModelWithParam:object];
    if ([model.fileObj.type isEqualToString:@"1"]) {//文件夹
        model.thumbNail = @"";//没有图片
    } else if ([model.fileObj.type isEqualToString:@"2"]) {//文档
        NSDictionary *firstImg = [FHReadFileSession firstImageDicByDoc:model.fileObj.objId];
        if (firstImg) {
            model.thumbNail = [NSString thumbImagePath:firstImg[@"name"]];
        } else {
            model.thumbNail = [NSString thumbImagePath:@"placeHolder.jpg"];
        }
        if (![LZFileManager isExistsAtPath:model.thumbNail]) {
            [LZFileManager copyItemAtPath:[NSString getLocalPlaceHolderFile] toPath:model.thumbNail overwrite:YES];
        }
    }
    return model;
}

- (FHFileCellModel *)fileModelWithId:(NSString *)objId {
    __block FHFileCellModel *model;
    [self.dataArray enumerateObjectsUsingBlock:^(FHFileCellModel *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.fileObj.objId isEqualToString:objId]) {
            model = obj;
            *stop = YES;
        }
    }];
    return model;
}

#pragma mark -- getter and setters
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

- (NSString *)selectedObjectId {
    NSString *objId;
    if (self.selectedIndex) {
        if (self.selectedIndex.item < self.dataArray.count) {
            FHFileCellModel *model = self.dataArray[self.selectedIndex.item];
            objId = model.fileObj.objId;
        }
    }
    return objId;
}

- (BOOL)canSelectedToEdit {
    if (self.selectedIndex) {
        if (self.selectedIndex.item < self.dataArray.count) {
            FHFileCellModel *model = self.dataArray[self.selectedIndex.item];
            if ([model.fileObj.type isEqualToString:@"2"]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
