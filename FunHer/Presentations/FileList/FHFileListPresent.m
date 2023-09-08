//
//  FHFileListPresent.m
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import "FHFileListPresent.h"
#import "FHFileCellModel.h"
#import "FHReadFileSession.h"
#import "FHFileModel.h"
#import "FHFileDataSession.h"
#import "FHPDFTool.h"

@implementation FHFileListPresent

#pragma mark -- Delegate
- (void)selectItemCount:(NSString *)num indexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -- public methods
#pragma mark -- 新建文件夹
- (void)createFolderWithName:(NSString *)name {
    [FHFileDataSession addFolder:name atParent:FHParentIdByHome];
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
    NSDictionary *doc = [FHFileDataSession addDocument:[NSString defaultDocName] withParentId:FHParentIdByHome];
    //新增图片数据
    [FHFileDataSession addImage:originalName byIndex:0 withParentId:doc[@"Id"]];
    [LZFileManager removeItemAtPath:[NSString imageTempBox]];//清空临时目录
    return doc;
}

- (void)createDocWithImages:(NSArray *)imgs {
    NSString *docName = [NSString defaultDocName];
    [self createDoc:docName withImages:imgs];
}

- (NSDictionary *)createDoc:(NSString *)name withImages:(NSArray *)imgs {
    NSDictionary *doc = [FHFileDataSession addDocument:name withParentId:FHParentIdByHome];
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
//    NSString *imgName = [NSString nameByRemoveIndex:imgPath.fileName];
//    NSString *originalPath = [[NSString originalDir] stringByAppendingPathComponent:imgName];
//    [LZFileManager copyItemAtPath:imgPath toPath:originalPath overwrite:YES];
}


- (void)refreshData {
    [self loadData];
}

#pragma mark -- private methods
- (void)loadData {
    NSMutableArray *temp = @[].mutableCopy;
    NSArray *homeFolderList = [FHReadFileSession entityListToDic:[FHReadFileSession homeFoldersBySorted]];
    NSArray *homeDocList = [FHReadFileSession entityListToDic:[FHReadFileSession homeDocumentsBySorted]];
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
            model.thumbNail = [[NSString thumbDir] stringByAppendingPathComponent:firstImg[@"name"]];
        } else {
            model.thumbNail = [[NSString thumbDir] stringByAppendingPathComponent:@"placeHolder.jpg"];
        }
        if (![LZFileManager isExistsAtPath:model.thumbNail]) {
            [LZFileManager copyItemAtPath:[NSString getLocalPlaceHolderFile] toPath:model.thumbNail overwrite:YES];
        }
    }
    return model;
}

#pragma mark -- PDF拆分成images 创建文档
- (NSDictionary *)getImagesFromPDF:(NSURL *)aUrl {
    NSString *fileName = [aUrl lastPathComponent];
    NSArray *imgArr = [FHPDFTool splitPDF:aUrl atDoc:[NSString tempDocPath]];
    return [self createDoc:[fileName fileNameNOSuffix] withImages:imgArr];
}

- (NSDictionary *)getImageCreateDoc:(NSURL *)aUrl {
    NSData *imgData = [NSData dataWithContentsOfURL:aUrl];
    if (imgData.length > 0) {
        NSString *fileName = [NSString stringWithFormat:@"%@%@",[NSString imageName], FHFilePathExtension];
        //保存原图
        [imgData writeToFile:[NSString originalImagePath:fileName] atomically:YES];
        [self saveSampleImage:[UIImage imageWithData:imgData] withName:fileName];
        //新增文档数据
        NSDictionary *doc = [FHFileDataSession addDocument:[NSString defaultDocName] withParentId:FHParentIdByHome];
        //新增图片数据
        [FHFileDataSession addImage:fileName byIndex:0 withParentId:doc[@"Id"]];
        return doc;
    }
    return nil;
}

- (NSDictionary *)handlePickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    [LZFileManager removeItemAtPath:[NSString tempDocPath]];
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        __block NSDictionary *doc;
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init]; NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) { //读取文件
            if (error) {
                NSLog(@"读取错误error == %@",error);
            } else {
                NSString *fileName = [newURL lastPathComponent];
                NSString *lowString = fileName.lowercaseString;
                if ([lowString hasSuffix:@".pdf"]) {
                    doc = [self getImagesFromPDF:newURL];
                } else if ([lowString hasSuffix:@".jpg"] || [lowString hasSuffix:@".png"]|| [lowString hasSuffix:@".jpeg"]) {
                    doc = [self getImageCreateDoc:newURL];
                }
            }
        }];
        return doc;
    }
    return nil;
}

#pragma mark -- getter and setters
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

- (NSArray *)funcItems {
    return @[@{@"image": @"input_doc", @"title": @"Import Files", @"selector": @"addPhotoFromFiles"},
             @{@"image": @"input_phtoto", @"title": @"Import Images", @"selector": @"addPhotoFromLibrary"},
             @{@"image": @"add_folder", @"title": @"CreateFolders", @"selector": @"addNewFolder"},
    ];
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

//    [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
//        dispatch_queue_t serial_queue = YYDispatchQueueGetForQOS(NSQualityOfServiceUserInitiated);
//        dispatch_group_async(groupE, serial_queue, ^{
//            NSData *data = [FHPhotoLibrary syncFetchOriginalImageDataWithAsset:asset];
//            [self saveOriginalPhoto:data atIndex:idx];
//        });
//    }];
//    dispatch_group_notify(groupE, dispatch_get_main_queue(), ^{
//        NSArray *array = [self coverPicArrayAtPath:[NSString tempDocPath]];
//        [self createDocWithImages:array];
//        [self refreshData];
//        if (completion) {
//            completion(array);
//        }
//    });
