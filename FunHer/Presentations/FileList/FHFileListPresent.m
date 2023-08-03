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

@implementation FHFileListPresent

- (instancetype)init {
    if (self = [super init]) {
        [self loadData];
    }
    return self;
}

#pragma mark -- Delegate
- (void)selectItemCount:(NSString *)num indexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -- public methods
#pragma mark -- 批量解析图片
- (void)anialysisAssets:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion {
    [LZFileManager removeItemAtPath:[NSString tempDocPath]];
    dispatch_group_t groupE = dispatch_group_create();
    [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_queue_t serial_queue = YYDispatchQueueGetForQOS(NSQualityOfServiceUserInitiated);
        dispatch_group_async(groupE, serial_queue, ^{
            NSData *data = [FHPhotoLibrary syncFetchOriginalImageDataWithAsset:asset];
            [self saveOriginalPhoto:data atIndex:idx];
        });
    }];
    dispatch_group_notify(groupE, dispatch_get_main_queue(), ^{
        NSArray *array = [self coverPicArrayAtPath:[NSString tempDocPath]];
        [self createDocWithImages:array];
        [self refreshData];
        if (completion) {
            completion(array);
        }
    });
}

- (void)createDocWithImages:(NSArray *)imgs {
    NSDictionary *doc = [FHFileDataSession addDocument:[NSDate timeFormatYMMDD:[NSDate date]] withParentId:FHParentIdByHome];
    [imgs enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *thumbName = [NSString nameByRemoveIndex:name];
        [FHFileDataSession addImage:thumbName byIndex:idx withParentId:doc[@"Id"]];
    }];
}

- (void)refreshData {
    [self loadData];
}

#pragma mark -- 图片排序,根据图片的后几位数字去排序
- (NSArray *)coverPicArrayAtPath:(NSString *)path  {
    NSArray *temp =  [LZFileManager listFilesInDirectoryAtPath:path deep:NO];;
    //排序,根据图片的后几位数字去排序
    NSArray *sortArray = [temp sortedArrayUsingComparator:^NSComparisonResult(NSString *tempContentPath1, NSString *tempContentPath2) {
        NSString *sortNO1 = [tempContentPath1 fileIndex];
        NSString *sortNO2 = [tempContentPath2 fileIndex];
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return sortArray;
}

- (void)saveOriginalPhoto:(NSData *)data atIndex:(NSUInteger)idx {
    NSString *imgPath = [NSString imagePathAtTempDocWithIndex:idx];
    BOOL result = [data writeToFile:imgPath atomically:YES];
    if (!result) {
        [self getEventWithName:@"write error"];
    } else {
        NSString *thumbName = [NSString nameByRemoveIndex:imgPath.fileName];
        NSString *thumbDirPath = [[NSString thumbDir] stringByAppendingPathComponent:thumbName];
        [LZFileManager copyItemAtPath:imgPath toPath:thumbDirPath overwrite:YES];
    }
}

#pragma mark -- private methods
- (void)loadData {
    NSMutableArray *temp = @[].mutableCopy;
    NSArray *homeDocList = [FHReadFileSession entityListToDic:[FHReadFileSession homeDocumentsBySorted]];
    for (NSDictionary *object in homeDocList) {
        FHFileCellModel *model = [FHFileCellModel createModelWithParam:object];
        NSDictionary *firstImg = [FHReadFileSession firstImageDicByDoc:model.fileObj.objId];
        if (firstImg) {
            model.thumbNail = [[NSString thumbDir] stringByAppendingPathComponent:firstImg[@"name"]];
        }
        [temp addObject:model];
    }
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
