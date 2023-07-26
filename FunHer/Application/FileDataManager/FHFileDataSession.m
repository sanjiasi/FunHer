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

@implementation FHFileDataSession
#pragma mark ** 文件夹
#pragma mark -- 增加文件夹
+ (NSDictionary *)addFolder:(NSString *)name atParent:(NSString *)parentId {
    NSDictionary *dic;
    NSString *pathId = parentId;
    if (![parentId isEqualToString:FHParentIdByHome]) {//区分是首页的文件夹
        FolderRLM *folderEntity = [LZFolderManager entityWithId:parentId];
        if (folderEntity) {
            pathId = folderEntity.pathId;
            [self updateFolder:parentId byTransaction:^{
                folderEntity.uTime = [NSDate utcStamp];
            }];
        }
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
    RLMResults<DocRLM *> *docs = [FHReadFileSession documentsAtFoler:objId];
    [self removeDocList:docs];
    
    RLMResults<ImageRLM *> *imgs = [FHReadFileSession allImagesAtFolder:objId];
    [self removeImageList:imgs];
    
    FolderRLM *appFolder = [LZFolderManager entityWithId:objId];
    [self removeFolder:appFolder];
}

#pragma mark -- 修改文件夹名称
+ (void)editFolderName:(NSString *)name withId:(NSString *)objId {
    FolderRLM *appFolder = [LZFolderManager entityWithId:objId];
    if (!appFolder) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    [self updateFolder:objId byTransaction:^{
        appFolder.uTime = [NSDate utcStamp];
        appFolder.name = name;
        appFolder.syncDone = NO;
    }];
}

#pragma mark -- 修改文件夹密码
+ (void)editFolderPassword:(NSString *)password withId:(NSString *)objId {
    FolderRLM *appFolder = [LZFolderManager entityWithId:objId];
    if (!appFolder) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    [self updateFolder:objId byTransaction:^{
        appFolder.uTime = [NSDate utcStamp];
        appFolder.password = password;
        appFolder.syncDone = NO;
    }];
}

#pragma mark -- 修改文件夹路径：移动
+ (void)editFolder:(NSString *)objId withParentId:(NSString *)parentId  {
    NSString *pathId = parentId;
    if (![parentId isEqualToString:FHParentIdByHome]) {//区分是首页的文件夹
        FolderRLM *folderEntity = [LZFolderManager entityWithId:parentId];
        if (folderEntity) {
            pathId = folderEntity.pathId;
            [self updateFolder:parentId byTransaction:^{
                folderEntity.uTime = [NSDate utcStamp];
            }];
        }
    }
    FolderRLM *appFolder = [LZFolderManager entityWithId:objId];
    NSString *oldPathId = appFolder.pathId;
    NSString *newPathId =  [pathId stringByAppendingPathComponent:objId];
    [LZFolderManager updateTransactionWithBlock:^{
        appFolder.parentId = parentId;
        appFolder.pathId = newPathId;
        appFolder.uTime = [NSDate utcStamp];
        
        RLMResults<FolderRLM *> *folders = [FHReadFileSession foldersAtFile:objId];//子文件夹
        for (FolderRLM *folderObj in folders) {
            folderObj.pathId = [folderObj.pathId stringByReplacingOccurrencesOfString:oldPathId withString:newPathId];
            folderObj.uTime = [NSDate utcStamp];
        }
        RLMResults<DocRLM *> *docs = [FHReadFileSession documentsAtFoler:objId];//子文档
        for (DocRLM *docObj in docs) {
            docObj.pathId = [docObj.pathId stringByReplacingOccurrencesOfString:oldPathId withString:newPathId];
            docObj.uTime = [NSDate utcStamp];
            docObj.syncDone = NO;
        }
        RLMResults<ImageRLM *> *images = [FHReadFileSession allImagesAtFolder:objId];//子图片
        for (ImageRLM *imgObj in images) {
            imgObj.pathId = [imgObj.pathId stringByReplacingOccurrencesOfString:oldPathId withString:newPathId];
            imgObj.uTime = [NSDate utcStamp];
            imgObj.syncDone = NO;
        }
    }];
    // 记录移动
}

#pragma mark -- 根据parentId获取上层目录的pathId
+ (NSString *)pathIdByParentId:(NSString *)parentId {
    NSString *pathId = parentId;
    if (![parentId isEqualToString:FHParentIdByHome]) {//区分是首页的文件夹
        FolderRLM *folderEntity = [LZFolderManager entityWithId:parentId];
        if (folderEntity) {
            pathId = folderEntity.pathId;
            [self updateFolder:parentId byTransaction:^{
                folderEntity.uTime = [NSDate utcStamp];
            }];
        }
    }
    return pathId;
}

#pragma mark -- 拷贝文件夹：（生成一份新数据，不删除老数据）
+ (void)copyFolder:(NSString *)objId withParentId:(NSString *)parentId {
    NSString *pathId = [self pathIdByParentId:parentId];
    FolderRLM *folderEntity = [LZFolderManager entityWithId:objId];;//移动对象文件夹
    FolderRLM *newFather = [[FolderRLM alloc] initWithValue:folderEntity];
    newFather.Id = [[NSUUID UUID] UUIDString];
    newFather.parentId = parentId;
    newFather.pathId = [pathId stringByAppendingPathComponent:newFather.Id];
    newFather.uTime = [NSDate utcStamp];
    newFather.syncDone = NO;
    [self createFolder:newFather];
    [self copyFolderDB:newFather withOldFolder:objId];
}

+ (void)copyFolderDB:(FolderRLM *)newFather withOldFolder:(NSString *)objId {
    RLMResults<FolderRLM *> *folders = [FHReadFileSession foldersByParentId:objId];//次一层下的文件夹
    for (FolderRLM *folderObj in folders) {
        FolderRLM *copyFolder = [[FolderRLM alloc] initWithValue:folderObj];
        copyFolder.Id = [[NSUUID UUID] UUIDString];
        copyFolder.parentId = newFather.Id;
        copyFolder.pathId = [newFather.pathId stringByAppendingPathComponent:copyFolder.Id];
        copyFolder.syncDone = NO;
        [self createFolder:copyFolder];
        [self copyFolderDB:copyFolder withOldFolder:folderObj.Id];
    }
    RLMResults<DocRLM *> *docs = [FHReadFileSession documentsByParentId:objId];
    for (DocRLM *docObj in docs) {
        [self editDocumentPath:docObj.Id withParentId:objId];
    }
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
    entity.pathId = [pathId stringByAppendingPathComponent:entity.Id];
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
        if (folderEntity) {
            pathId = folderEntity.pathId;
            [self updateFolder:parentId byTransaction:^{
                folderEntity.uTime = [NSDate utcStamp];
            }];
        }
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
    if (!appDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    [self removeDoc:appDoc];
}

#pragma mark -- 修改文档名称
+ (void)editDocumentName:(NSString *)name withId:(NSString *)objId {
    DocRLM *appDoc = [LZDocManager entityWithId:objId];
    if (!appDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    [self updateDoc:objId byTransaction:^{
        appDoc.uTime = [NSDate utcStamp];
        appDoc.name = name;
        appDoc.syncDone = NO;
    }];
}
#pragma mark -- 修改文档密码
+ (void)editDocumentPassword:(NSString *)password withId:(NSString *)objId {
    DocRLM *appDoc = [LZDocManager entityWithId:objId];
    if (!appDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    if (NULLString(appDoc.password) && NULLString(password)) {//没有密码的情况下，不需要对密码置空
        return;
    }
    [self updateDoc:objId byTransaction:^{
        appDoc.uTime = [NSDate utcStamp];
        appDoc.password = password;
        appDoc.syncDone = NO;
    }];
}

#pragma mark -- 修改文档浏览时间
+ (void)editDocumentReadingTimeWithId:(NSString *)objId {
    DocRLM *appDoc = [LZDocManager entityWithId:objId];
    if (!appDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    [self updateDoc:objId byTransaction:^{
        appDoc.rTime = [NSDate utcStamp];
    }];
}

#pragma mark -- 修改文档路径：移动
+ (void)editDocumentPath:(NSString *)objId withParentId:(NSString *)parentId {
    NSString *pathId = parentId;
    if (![parentId isEqualToString:FHParentIdByHome]) {//区分是首页的文档，还是folder下的文档
        FolderRLM *folderEntity = [LZFolderManager entityWithId:parentId];
        if (folderEntity) {
            pathId = folderEntity.pathId;
            [self updateFolder:parentId byTransaction:^{
                folderEntity.uTime = [NSDate utcStamp];
            }];
        }
    }
    DocRLM *appDoc = [LZDocManager entityWithId:objId];
    if (!appDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    RLMResults<ImageRLM *> *images = [FHReadFileSession imageRLMsByParentId:objId];
    NSString *docPathId = [pathId stringByAppendingPathComponent:objId];//[NSString stringWithFormat:@"%@/%@",pathId, objId];
    [LZDocManager updateTransactionWithBlock:^{
        appDoc.parentId = parentId;
        appDoc.pathId = docPathId;
        appDoc.uTime = [NSDate utcStamp];
        appDoc.syncDone = NO;
        for (ImageRLM *object in images) {
            object.pathId = [docPathId stringByAppendingPathComponent:object.Id];
            object.uTime = [NSDate utcStamp];
            object.syncDone = NO;
        }
    }];
    // 记录移动文档
}

#pragma mark -- 构造DocRLM
+ (DocRLM *)buildDocWithName:(NSString *)name atPath:(NSString *)pathId {
    DocRLM *documentModel = [[DocRLM alloc] init];
    documentModel.Id = [[NSUUID UUID] UUIDString];
    documentModel.parentId = [pathId fileName];
    documentModel.name = name;
    documentModel.pathId = [pathId stringByAppendingPathComponent:documentModel.Id];
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

#pragma mark -- 构造ImageRLM
+ (ImageRLM *)buildImageWithName:(NSString *)name atPath:(NSString *)pathId {
    ImageRLM *imageModel = [[ImageRLM alloc] init];
    imageModel.Id = [[NSUUID UUID] UUIDString];
    imageModel.parentId = [pathId fileName];
    imageModel.name = name;
    imageModel.pathId = [NSString stringWithFormat:@"%@/%@",pathId, imageModel.Id];
    imageModel.cTime = [NSDate utcStamp];
    imageModel.uTime = [NSDate utcStamp];
    return imageModel;
}

/// 增 -- img
+ (void)createImage:(ImageRLM *)entity {
    [LZImageManager addEntity:entity];
    NSLog(@"record add -- img =%@",entity.Id);
}

/// 改 -- img
+ (void)updateImage:(NSString *)objId byTransaction:(void(^)(void))transcation {
    [LZImageManager updateTransactionWithBlock:transcation];
    NSLog(@"record update -- img =%@",objId);
}

/// 删 -- img
+ (void)removeImage:(ImageRLM *)entity {
    NSLog(@"record delete -- doc =%@",entity.Id);
    [LZImageManager removeEntity:entity];
}

+ (void)removeImageList:(id)list {
    [LZImageManager removeEntityList:list];
}

@end
