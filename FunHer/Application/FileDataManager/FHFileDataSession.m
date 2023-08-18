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
    NSString *pathId = [self pathIdByParentId:parentId];
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
    
    //该目录下的文档
    RLMResults<DocRLM *> *docs = [FHReadFileSession documentsAtFoler:objId];
    
    RLMResults<ImageRLM *> *imgs = [FHReadFileSession allImagesAtFolder:objId];
    
    FolderRLM *appFolder = [LZFolderManager entityWithId:objId];
    
    [self removeImageList:imgs];
    [self removeDocList:docs];
    [self removeFolderList:folders];
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
+ (void)editFolderPath:(NSString *)objId withParentId:(NSString *)parentId  {
    NSString *pathId = [self pathIdByParentId:parentId];
    FolderRLM *appFolder = [LZFolderManager entityWithId:objId];
    NSString *oldPathId = appFolder.pathId;
    NSString *newPathId =  [pathId stringByAppendingPathComponent:objId];
    [LZFolderManager updateTransactionWithBlock:^{
        RLMResults<FolderRLM *> *folders = [FHReadFileSession foldersAtFile:objId];//子文件夹
        RLMResults<DocRLM *> *docs = [FHReadFileSession documentsAtFoler:objId];//子文档
        RLMResults<ImageRLM *> *images = [FHReadFileSession allImagesAtFolder:objId];//子图片
        for (FolderRLM *folderObj in folders) {
            folderObj.pathId = [folderObj.pathId stringByReplacingOccurrencesOfString:oldPathId withString:newPathId];
            folderObj.uTime = [NSDate utcStamp];
        }
        
        for (DocRLM *docObj in docs) {
            docObj.pathId = [docObj.pathId stringByReplacingOccurrencesOfString:oldPathId withString:newPathId];
            docObj.uTime = [NSDate utcStamp];
            docObj.syncDone = NO;
        }
        
        for (ImageRLM *imgObj in images) {
            imgObj.pathId = [imgObj.pathId stringByReplacingOccurrencesOfString:oldPathId withString:newPathId];
            imgObj.uTime = [NSDate utcStamp];
            imgObj.syncDone = NO;
        }
        appFolder.parentId = parentId;
        appFolder.pathId = newPathId;
        appFolder.uTime = [NSDate utcStamp];
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
    if (!folderEntity) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    FolderRLM *newFather = [[FolderRLM alloc] initWithValue:folderEntity];
    newFather.Id = [[NSUUID UUID] UUIDString];
    newFather.parentId = parentId;
    newFather.pathId = [pathId stringByAppendingPathComponent:newFather.Id];
    newFather.uTime = [NSDate utcStamp];
    newFather.syncDone = NO;
    [LZFolderManager addEntity:newFather];
    [self copyFolderDB:newFather withOldFolder:objId];
    //记录拷贝文件夹
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
        [self copyDocument:docObj.Id withParentId:objId];
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
    NSString *pathId = [self pathIdByParentId:parentId];
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
    DocRLM *appDoc = [LZDocManager entityWithId:objId];
    if (!appDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    NSString *pathId = [self pathIdByParentId:parentId];
    RLMResults<ImageRLM *> *images = [FHReadFileSession imageRLMsByParentId:objId];
    NSString *docPathId = [pathId stringByAppendingPathComponent:objId];
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

#pragma mark -- 拷贝文档
+ (void)copyDocument:(NSString *)objId withParentId:(NSString *)parentId {
    DocRLM *appDoc = [LZDocManager entityWithId:objId];
    if (!appDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    NSString *pathId = [self pathIdByParentId:parentId];
    DocRLM *copyDoc = [self buildDocWithName:appDoc.name atPath:pathId];
    
    RLMResults<ImageRLM *> *imgs = [FHReadFileSession imageRLMsByParentId:objId];
    NSMutableArray *copyImgs = @[].mutableCopy;
    for (ImageRLM *imgFile in imgs) {
        ImageRLM *copyImg = [self buildImageWithName:imgFile.name byIndex:imgFile.picIndex atPath:copyDoc.pathId];
        [copyImgs addObject:copyImg];
    }
    [LZImageManager batchAddEntityList:copyImgs];
    [LZDocManager addEntity:copyDoc];
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
#pragma mark -- 新增图片
+ (NSDictionary *)addImage:(NSString *)name byIndex:(NSInteger)index withParentId:(NSString *)parentId {
    NSDictionary *dic;
    DocRLM *appDoc = [LZDocManager entityWithId:parentId];
    if (!appDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return dic;}
    NSString *pathId = appDoc.pathId;
    ImageRLM *entity = [self buildImageWithName:name byIndex:index atPath:pathId];
    if (entity) {
        [self createImage:entity];
        dic = [entity modelToDic];
    }
    return dic;
}

#pragma mark -- 删除图片
+ (void)deleteImageWithId:(NSString *)objId {
    ImageRLM *image = [LZImageManager entityWithId:objId];
    if (!image) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    [self removeImage:image];
}

#pragma mark -- 更新图片
+ (void)updateImageWithId:(NSString *)objId {
    ImageRLM *image = [LZImageManager entityWithId:objId];
    if (!image) { [self getEventWithName:NSStringFromSelector(_cmd)]; return;}
    [self updateImage:objId byTransaction:^{
        image.uTime = [NSDate utcStamp];
        image.fileLength = [[LZFileManager sizeOfFileAtPath:image.filePath] longValue];
        image.cloudUrl = @"";
        image.syncDone = NO;
    }];
}

#pragma mark -- 批量修改图片路径：移动 文档的所有图片
+ (NSArray *)batchEditImagesWithParentId:(NSString *)parentId toNewDoc:(NSString *)newDocId {
    DocRLM *doc = [LZDocManager entityWithId:parentId];
    if (!doc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return @[];}
    NSArray *imgIds = [self imageIdsByParentId:parentId];
    NSArray *newImgs = [self batchMoveImageWithIds:imgIds toNewDoc:newDocId];
    [self removeDoc:doc];
    return newImgs;
}

#pragma mark -- 批量移动图片 文档的部分图片 修改parentId、pathId、picIndex
+ (NSArray *)batchMoveImageWithIds:(NSArray *)imageIds toNewDoc:(NSString *)newDocId  {
    DocRLM *newDoc = [LZDocManager entityWithId:newDocId];
    if (!newDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return @[];}
    NSMutableArray *newImages = @[].mutableCopy;
    NSMutableArray *images = [FHReadFileSession imageRLMsOrderByImageIds:imageIds];
    NSInteger start = [FHReadFileSession lastImageIndexByParentId:newDocId] + 1;
    [LZImageManager updateTransactionWithBlock:^{
        for (int i = 0; i < images.count; i++) {
            if (i < images.count) {//
                ImageRLM *imgEntity = images[i];
                imgEntity.picIndex = i + start;
                imgEntity.parentId = newDocId;
                imgEntity.pathId = [newDoc.pathId stringByAppendingPathComponent:imgEntity.Id];
                imgEntity.uTime = [NSDate utcStamp];
                imgEntity.syncDone = NO;
                [newImages addObject:imgEntity];
            }
        }
    }];
    
    return [NSArray arrayWithArray:newImages];
}

#pragma mark -- 批量复制文档的所有图片
+ (NSArray *)batchCopytImagesAtParentId:(NSString *)parentId toNewDoc:(NSString *)newDocId {
    NSArray *imgIds = [self imageIdsByParentId:parentId];
    NSArray *newImgs = [self batchCopyImageWithIds:imgIds toNewDoc:newDocId];
    return newImgs;
}

#pragma mark -- 批量复制图片 修改parentId、pathId、picIndex
+ (NSArray *)batchCopyImageWithIds:(NSArray *)imageIds toNewDoc:(NSString *)newDocId {
    DocRLM *newDoc = [LZDocManager entityWithId:newDocId];
    if (!newDoc) { [self getEventWithName:NSStringFromSelector(_cmd)]; return @[];}
    NSMutableArray *newImages = @[].mutableCopy;
    NSMutableArray *images = [FHReadFileSession imageRLMsOrderByImageIds:imageIds];
    NSInteger start = [FHReadFileSession lastImageIndexByParentId:newDocId] + 1;
    for (int i = 0; i < images.count; i++) {
        if (i < images.count) {//
            ImageRLM *imgEntity = images[i];
            NSInteger picIndex = i + start;
            ImageRLM *copyImg = [self buildImageWithName:imgEntity.name byIndex:picIndex atPath:newDoc.pathId];
            [newImages addObject:copyImg];
        }
    }
    [self batchCreateImages:newImages];
    [self updateDoc:newDocId byTransaction:^{
        newDoc.uTime = [NSDate utcStamp];
    }];
    //记录修改文档
    return [NSArray arrayWithArray:newImages];
}

+ (NSArray *)imageIdsByParentId:(NSString *)parentId {
    RLMResults<ImageRLM *> *sortImgs = [FHReadFileSession sortImageRLMsByParentId:parentId];
    NSMutableArray *imgIds = @[].mutableCopy;
    for (ImageRLM *object in sortImgs) {
        [imgIds addObject:object.Id];
    }
    return [NSArray arrayWithArray:imgIds];
}

#pragma mark -- 构造ImageRLM
+ (ImageRLM *)buildImageWithName:(NSString *)name byIndex:(NSInteger)index atPath:(NSString *)pathId {
    ImageRLM *imageModel = [[ImageRLM alloc] init];
    imageModel.Id = [[NSUUID UUID] UUIDString];
    imageModel.parentId = [pathId fileName];
    imageModel.pathId = [pathId stringByAppendingPathComponent:imageModel.Id];
    imageModel.name = name;
    imageModel.picIndex = index;
    imageModel.fileLength = [[LZFileManager sizeOfFileAtPath:imageModel.filePath] longValue];
    imageModel.cTime = [NSDate utcStamp];
    imageModel.uTime = [NSDate utcStamp];
    return imageModel;
}

/// 增 -- img
+ (void)createImage:(ImageRLM *)entity {
    [LZImageManager addEntity:entity];
    NSLog(@"record add -- img =%@",entity.Id);
}

+ (void)batchCreateImages:(NSArray *)entityList {
    [LZImageManager batchAddEntityList:entityList];
    [entityList enumerateObjectsUsingBlock:^(ImageRLM *entity, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"record add -- img =%@",entity.Id);
    }];
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
