//
//  FHEditItemPresent.m
//  FunHer
//
//  Created by GLA on 2023/9/8.
//

#import "FHEditItemPresent.h"
#import "FHFileModel.h"
#import "FHFileEditCellModel.h"
#import "FHReadFileSession.h"
#import "FHFileDataSession.h"

@implementation FHEditItemPresent

#pragma mark -- public methods
- (void)refreshData {
    [self loadData];
}

- (void)handSelectedAll {
    self.selectedAll = !self.selectedAll;
    [self.dataArray enumerateObjectsUsingBlock:^(FHFileEditCellModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.fileObj.type isEqualToString:@"2"]) {
            obj.isSelected = self.selectedAll;
        }
    }];
}

- (NSArray *)selectedItemArray {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected = 1"];
    NSArray *results = [self.dataArray filteredArrayUsingPredicate:predicate];
    NSMutableArray *allDocs = @[].mutableCopy;
    [self.dataArray enumerateObjectsUsingBlock:^(FHFileEditCellModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.fileObj.type isEqualToString:@"2"]) {
            [allDocs addObject:obj];
        }
    }];
    self.selectedAll = results.count == allDocs.count;//全选
    
    NSMutableArray *data = @[].mutableCopy;
    [self.funcItems enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *selectorName = obj[@"selector"];
        BOOL enable = results.count > 0;
        if ([selectorName isEqualToString:@"mergeAction"]) {
            enable = results.count > 1;
        }
        NSMutableDictionary *temp = obj.mutableCopy;
        [temp setValue:@(enable) forKey:@"enable"];
        [data addObject:[NSDictionary dictionaryWithDictionary:temp]];
    }];
    self.funcItems = data;
    return results;
}

#pragma mark -- 分享
- (NSArray *)shareFiles {
    NSMutableArray *temp = @[].mutableCopy;
    NSArray *results = [self selectedItemArray];
    [results enumerateObjectsUsingBlock:^(FHFileEditCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *imageArr = [FHReadFileSession entityListToDic:[FHReadFileSession imageRLMsByParentId:obj.fileObj.objId]];
        NSMutableArray *fileArr = @[].mutableCopy;
        [imageArr enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull imgFile, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *fileName = imgFile[@"name"];
            NSURL *itemUrl = [NSURL fileURLWithPath:[NSString sampleImagePath:fileName]];
            if (itemUrl) {
                [fileArr addObject:itemUrl];
            }
        }];
        [temp addObjectsFromArray:fileArr];
    }];
    return [NSArray arrayWithArray:temp];
}

#pragma mark -- 合并
- (NSString *)mergeFiles {
    __block NSString *docId;
    NSArray *results = [self selectedItemArray];
    [results enumerateObjectsUsingBlock:^(FHFileEditCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {//第一个为主文件
            docId = [FHFileDataSession copyDocument:obj.fileObj.objId withParentId:self.parentId];
        } else {
            if (docId) {
                [FHFileDataSession batchCopytImagesAtParentId:obj.fileObj.objId toNewDoc:docId];
            }
        }
    }];
    return docId;
}

- (NSString *)mergeFilesDeleteOldFile {
    __block NSString *docId;
    NSArray *results = [self selectedItemArray];
    [results enumerateObjectsUsingBlock:^(FHFileEditCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {//第一个为主文件
            docId = obj.fileObj.objId;
            return;
        } else {
            if (docId) {
                [FHFileDataSession batchMoveImagesWithParentId:obj.fileObj.objId toNewDoc:docId];
            }
        }
    }];
    return docId;
}

#pragma mark -- 移动
- (void)moveFileToFolder:(NSString *)folderId {
    NSString *parentID = folderId;
    NSArray *results = [self selectedItemArray];
    [results enumerateObjectsUsingBlock:^(FHFileEditCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [FHFileDataSession editDocumentPath:obj.fileObj.objId withParentId:parentID];
    }];
}

#pragma mark -- 复制
- (void)copyFileToFolder:(NSString *)folderId {
    NSString *parentID = folderId;
    NSArray *results = [self selectedItemArray];
    [results enumerateObjectsUsingBlock:^(FHFileEditCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [FHFileDataSession copyDocument:obj.fileObj.objId withParentId:parentID];
    }];
}

#pragma mark -- 删除
- (void)deleteFiles {
    NSArray *results = [self selectedItemArray];
    [results enumerateObjectsUsingBlock:^(FHFileEditCellModel *   _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [FHFileDataSession deleteDocumentWithId:obj.fileObj.objId];
    }];
}

#pragma mark -- private methods
- (void)loadData {
    NSMutableArray *temp = @[].mutableCopy;
    NSArray *homeFolderList = [FHReadFileSession entityListToDic:[FHReadFileSession foldersByParentId:self.parentId]];
    NSArray *homeDocList = [FHReadFileSession entityListToDic:[FHReadFileSession documentsByParentId:self.parentId]];
    NSMutableArray *dataArr = [NSMutableArray arrayWithArray:homeFolderList];
    [dataArr addObjectsFromArray:homeDocList];
    [dataArr enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL * _Nonnull stop) {
        FHFileEditCellModel *model = [self buildCellModelWihtObject:object];
        if (model) {
            model.isSelected = [model.fileObj.objId isEqualToString:self.selectedItem];
            [temp addObject:model];
        }
    }];
    self.dataArray = temp;
}

- (FHFileEditCellModel *)buildCellModelWihtObject:(NSDictionary *)object {
    FHFileEditCellModel *model = [FHFileEditCellModel createModelWithParam:object];
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

#pragma mark -- getter and setters
- (NSMutableArray *)funcItems {
    if (!_funcItems) {
        BOOL enableEdit = self.selectedItem ? YES : NO;
        _funcItems = @[@{@"image": @"edit_share", @"title": @"Share", @"selector": @"shareAction", @"enable":@(enableEdit)},
                       @{@"image": @"edit_copy", @"title": @"Move/Copy", @"selector": @"copyAcion", @"enable":@(enableEdit)},
                       @{@"image": @"edit_merge", @"title": @"Merge", @"selector": @"mergeAction", @"enable":@(NO)},
                       @{@"image": @"edit_delete", @"title": @"Delete", @"selector": @"deleteAction", @"enable":@(enableEdit)},
        ].mutableCopy;
    }
    return _funcItems;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

@end
