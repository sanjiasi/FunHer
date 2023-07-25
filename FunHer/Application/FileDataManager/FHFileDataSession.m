//
//  FHFileDataSession.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "FHFileDataSession.h"
#import "FolderRLM.h"
#import "LZFolderManager.h"
#import "DocRLM.h"
#import "LZDocManager.h"
#import "ImageRLM.h"
#import "LZImageManager.h"
#import "LZDBService.h"
#import "FHReadFileSession.h"

NSString * const FHParentIdByHome            = @"FF_00";//首页文件夹、文档的父id

@implementation FHFileDataSession
#pragma mark ** 文件夹
#pragma mark -- 增加文件夹
+ (NSDictionary *)addFolder:(NSString *)name atParent:(NSString *)parentId {
    NSDictionary *dic;
    NSString *pathId = parentId;
    if (![parentId isEqualToString:FHParentIdByHome]) {//区分是首页的文件夹
        FolderRLM *folderEntity = [LZFolderManager entityWithId:parentId];
        pathId = folderEntity.pathId;
    }
    FolderRLM *entity = [self buildFolderWithName:name atPath:pathId];
    if (entity) {
        [self createFolder:entity];
        dic = [entity modelToDic];
    }
    return dic;
}

#pragma mark -- 删除文件夹
+ (void)deleteFolderWithId:(NSString *)objId {
    //目录下的文件夹
    //该目录下的文件夹
    RLMResults<FolderRLM *> *folders = [FHReadFileSession foldersAtFile:objId];
    [self removeFolderList:folders];
    //该目录下的文档
    RLMResults<DocRLM *> *docs; //= [FHReadFileSession documentsAtFoler:docId];
    [LZDBService removeAllObjects:docs];
    
    RLMResults<ImageRLM *> *imgs;// = [FHReadFileSession allImagesAtFolder:docId];
    [LZDBService removeAllObjects:imgs];
    
    FolderRLM *appFolder = [LZFolderManager entityWithId:objId];
    [self removeFolder:appFolder];
}

#pragma mark -- 修改文件夹名称
+ (void)editFolderName:(NSString *)name withId:(NSString *)objId {
    FolderRLM *appFolder = [LZFolderManager entityWithId:objId];
    [self updateFolder:objId byTransaction:^{
        appFolder.uTime = [NSDate utcStamp];
        appFolder.name = name;
    }];
}

#pragma mark -- 修改文件夹密码
+ (void)editFolderPassword:(NSString *)password withId:(NSString *)objId {
    FolderRLM *appFolder = [LZFolderManager entityWithId:objId];
    [self updateFolder:objId byTransaction:^{
        appFolder.uTime = [NSDate utcStamp];
        appFolder.password = password;
    }];
}

#pragma mark -- 批量修改文件夹
+ (void)batchUpdateFolders:(NSArray *)folderIds withData:(NSDictionary *)data {
    [LZFolderManager batchUpdateEntityInfo:data byEntityIds:folderIds];
}

/// 增 -- folder
+ (void)createFolder:(FolderRLM *)entity {
    [LZFolderManager addEntity:entity];
    NSLog(@"record add -- folder =%@",entity.Id);
}

/// 改 -- folder
+ (void)updateFolder:(NSString *)objId byTransaction:(void(^)(void))transcation {
    [LZFolderManager updateTransactionWithBlock:transcation];
    NSLog(@"record update -- folder =%@",objId);
}

/// 删 -- folder
+ (void)removeFolder:(FolderRLM *)entity {
    NSLog(@"record delete -- folder =%@",entity.Id);
    [LZFolderManager removeEntity:entity];
}

+ (void)removeFolderList:(id)list {
    [LZFolderManager removeEntityList:list];
}

#pragma mark -- 构造FolderRLM
+ (FolderRLM *)buildFolderWithName:(NSString *)name atPath:(NSString *)pathId {
    FolderRLM *entity = [[FolderRLM alloc] init];
    entity.Id = [[NSUUID UUID] UUIDString];
    entity.parentId = [pathId fileName];
    entity.name = name;
    entity.pathId = [pathId stringByAppendingPathComponent:name];
    entity.cTime = [NSDate utcStamp];
    entity.uTime = [NSDate utcStamp];
    
    return entity;
}

#pragma mark ** 文档
#pragma mark -- 增加文档
+ (NSDictionary *)addDocument:(NSString *)name withParentId:(NSString *)parentId {
    NSDictionary *dic;
    NSString *pathId = parentId;
    if (![parentId isEqualToString:FHParentIdByHome]) {//区分是首页的文档，还是folder下的文档
        FolderRLM *folderEntity = [LZFolderManager entityWithId:parentId];
        pathId = folderEntity.pathId;
        [self updateFolder:parentId byTransaction:^{
            folderEntity.uTime = [NSDate utcStamp];
        }];
    }
    DocRLM *entity = [self buildDocWithName:name atPath:pathId];
    if (entity) {
        [self createDoc:entity];
        dic = [entity modelToDic];
    }
    return dic;
}

#pragma mark -- 删除文档
+ (void)deleteDocumentWithId:(NSString *)objId {
    DocRLM *appDoc = [LZDocManager entityWithId:objId];
    [self removeDoc:appDoc];
}

#pragma mark -- 修改文档名称
+ (void)editDocumentName:(NSString *)name withId:(NSString *)objId {
    DocRLM *appDoc = [LZDocManager entityWithId:objId];
    [self updateDoc:objId byTransaction:^{
        appDoc.uTime = [NSDate utcStamp];
        appDoc.name = name;
        appDoc.syncDone = NO;
    }];
}
#pragma mark -- 修改文档密码
+ (void)editDocumentPassword:(NSString *)password withId:(NSString *)objId {
    DocRLM *appDoc = [LZDocManager entityWithId:objId];
    if (NULLString(appDoc.password) && NULLString(password)) {//没有密码的情况下，不需要对密码置空
        return;
    }
    [self updateDoc:objId byTransaction:^{
        appDoc.uTime = [NSDate utcStamp];
        appDoc.password = password;
    }];
}


#pragma mark -- 构造DocRLM
+ (DocRLM *)buildDocWithName:(NSString *)name atPath:(NSString *)pathId {
    DocRLM *documentModel = [[DocRLM alloc] init];
    documentModel.Id = [[NSUUID UUID] UUIDString];
    documentModel.parentId = [pathId fileName];
    documentModel.name = name;
    documentModel.pathId = [NSString stringWithFormat:@"%@/%@",pathId, documentModel.Id];
    documentModel.cTime = [NSDate utcStamp];
    documentModel.uTime = [NSDate utcStamp];
    documentModel.rTime = [NSDate utcStamp];
    return documentModel;
}

/// 增 -- doc
+ (void)createDoc:(DocRLM *)entity {
    [LZDocManager addEntity:entity];
    NSLog(@"record add -- doc =%@",entity.Id);
}

/// 改 -- doc
+ (void)updateDoc:(NSString *)objId byTransaction:(void(^)(void))transcation {
    [LZDocManager updateTransactionWithBlock:transcation];
    NSLog(@"record update -- doc =%@",objId);
}

/// 删 -- doc
+ (void)removeDoc:(DocRLM *)entity {
    NSLog(@"record delete -- doc =%@",entity.Id);
    [LZDocManager removeEntity:entity];
}

+ (void)removeDocList:(id)list {
    [LZDocManager removeEntityList:list];
}

#pragma mark ** 图片

@end
