//
//  FHReadFileSession.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "FHReadFileSession.h"
#import "FolderRLM.h"
#import "LZFolderManager.h"
#import "DocRLM.h"
#import "LZDocManager.h"
#import "ImageRLM.h"
#import "LZImageManager.h"
#import "LZDBService.h"

@implementation FHReadFileSession

#pragma mark -- 根据父id(文件夹上级目录id)查询folders 默认排序
+ (RLMResults<FolderRLM *> *)foldersByParentId:(NSString *)parentId {
    RLMResults<FolderRLM *> *folders = [LZFolderManager defaultSortByResults:[FolderRLM objectsWhere:@"parentId = %@",parentId]];
    return folders;
}

#pragma mark -- 查询首页的文件夹 默认排序
+ (RLMResults<FolderRLM *> *)homeFoldersBySorted {
    RLMResults<FolderRLM *> *folders = [self foldersByParentId:@"000000"];
    return folders;
}

#pragma mark -- 查询某个文件夹下的所有folder 可用于计数
+ (RLMResults<FolderRLM *> *)foldersAtFile:(NSString *)folderId {
    RLMResults<FolderRLM *> *folders = [FolderRLM objectsWhere:@"pathId CONTAINS %@ AND Id != %@", folderId, folderId];
    return folders;
}

#pragma mark -- 查询所有的文件夹 根据第一级目录排序：用于复制、移动的文件夹数据
+ (NSMutableArray *)allFoldersByFatherDirectorySorted {
    NSMutableArray *allData = @[].mutableCopy;
    NSMutableArray *folders = [self foldersByDocId:@"000000" data:allData];
    return folders;
}

//先加第一层的第一个文件及其所有子文件，后加第二个文件及其所有 -- 类推 01, 01/101, 02, 02/102
+ (NSMutableArray *)foldersByDocId:(NSString *)docId data:(NSMutableArray *)allData {
    if ([docId isEqualToString:@"000000"]) {
        RLMResults<FolderRLM *> *folders = [self foldersByParentId:docId];
        if (folders.count) {
            for (FolderRLM *obj in folders) {
                [self foldersByDocId:obj.Id data:allData];
            }
        } else {
            return allData;
        }
    } else {
        FolderRLM *folder = [LZFolderManager entityWithId:docId];
        if (folder) {
            [allData addObject:folder];
            RLMResults<FolderRLM *> *folders = [self foldersByParentId:folder.Id];
            if (folders.count) {
                for (FolderRLM *obj in folders) {
                    [self foldersByDocId:obj.Id data:allData];
                }
            } else {
                return allData;
            }
        } else {
            return allData;
        }
    }
    return allData;
}

#pragma mark -- 查询所有的文件夹 根据目录排序
+ (NSMutableArray *)allFoldersByDirectorySorted {
    NSMutableArray *allData = @[].mutableCopy;
    NSMutableArray *folders = [self foldersByParentId:@"000000" data:allData];
    return folders;
}


//先加第一层全部，后加第一层文件的子文件 -- 类推 01, 02, 01/101, 02/102
+ (NSMutableArray *)foldersByParentId:(NSString *)parentId data:(NSMutableArray *)allData {
    RLMResults<FolderRLM *> *folders = [self foldersByParentId:parentId];
    if (folders.count) {
        [allData addObjectsFromArray:[LZDBService convertToArray:folders]];
    } else {
        return allData;
    }
    for (FolderRLM *folderObj in folders) {
        [self foldersByParentId:folderObj.Id data:allData];
    }
    return allData;
}

@end
