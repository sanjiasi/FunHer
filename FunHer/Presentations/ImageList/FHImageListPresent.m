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
            [self saveOriginalPhoto:data atIndex:idx];
        }];
    }];
    [LZDispatchManager groupTask:groupE withCompleted:^{
        NSArray *array = [self coverPicArrayAtPath:[NSString tempDocPath]];
        
        [self refreshData];
        if (completion) {
            completion(array);
        }
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
    NSArray *imgList = [FHReadFileSession entityListToDic:[FHReadFileSession sortImageRLMsByParentId:self.fileObjId]];
    [imgList enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL * _Nonnull stop) {
        FHImageCellModel *model = [FHImageCellModel createModelWithParam:object];
        if ([model.fileObj.type isEqualToString:@"3"]) {//图片
            model.thumbNail = [[NSString thumbDir] stringByAppendingPathComponent:model.fileObj.name];
            model.fileName = [NSString stringWithFormat:@"%@",@(idx+1)];
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
