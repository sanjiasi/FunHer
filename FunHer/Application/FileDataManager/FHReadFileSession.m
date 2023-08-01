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

#pragma mark ** 文件夹
#pragma mark -- 根据父id(文件夹上级目录id)查询folders 排序
+ (RLMResults<FolderRLM *> *)foldersByParentId:(NSString *)parentId {
    RLMResults<FolderRLM *> *folders = [self sortResults:[FolderRLM objectsWhere:@"parentId = %@",parentId]];
    return folders;
}

#pragma mark -- 查询首页的文件夹 排序
+ (RLMResults<FolderRLM *> *)homeFoldersBySorted {
    RLMResults<FolderRLM *> *folders = [self foldersByParentId:@"000000"];
    return folders;
}


#pragma mark --  默认uTime(更新时间)降序
+ (RLMResults *)defaultSortByResults:(RLMResults *)results {
    return [results sortedResultsUsingKeyPath:@"uTime" ascending:NO];
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

#pragma mark ** 文档
#pragma mark 文件夹内的文档(非首页的文档)
+ (RLMResults<DocRLM *> *)allDocumentsAtFoler {
    RLMResults<DocRLM *> *documents = [self sortResults:[DocRLM objectsWhere:@"parentId != '000000'"]];
    return documents;
}

#pragma mark -- 查询所有的文档 最近浏览时间排序
+ (RLMResults<DocRLM *> *)allDocumentsByRecent {
    RLMResults<DocRLM *> *documents = [[DocRLM allObjects] sortedResultsUsingKeyPath:@"rtime" ascending:NO];
    return documents;
}

#pragma mark -- 根据父id(文档上级目录id)查询documents 默认排序
+ (RLMResults<DocRLM *> *)documentsByParentId:(NSString *)parentId {
    RLMResults<DocRLM *> *documents = [self sortResults:[DocRLM objectsWhere:@"parentId = %@",parentId]];
    return documents;
}

#pragma mark -- 查询首页的文档 默认排序
+ (RLMResults<DocRLM *> *)homeDocumentsBySorted {
    RLMResults<DocRLM *> *documents = [self documentsByParentId:@"000000"];
    return documents;
}

#pragma mark -- 查询某个文件夹下的所有文档 可用于计数
+ (RLMResults<DocRLM *> *)documentsAtFoler:(NSString *)folderId {
    FolderRLM *folder = [LZFolderManager entityWithId:folderId];
    RLMResults<DocRLM *> *documents = [DocRLM objectsWhere:@"pathId CONTAINS %@", folder.pathId];
    return documents;
}

#pragma mark ** 图片
#pragma mark -- 根据图片名称和父id(图片上级目录id)查询images
+ (RLMResults<ImageRLM *> *)imageRLMsByParentId:(NSString *)parentId withName:(NSString *)name {
    RLMResults<ImageRLM *> *images = [ImageRLM objectsWhere:@"parentId = %@ AND name = %@",parentId, name];
    return images;
}

#pragma mark -- 计数某个目录下的所有图片个数 pathId:路径id
+ (RLMResults<ImageRLM *> *)imagesAtPath:(NSString *)pathId {
    RLMResults<ImageRLM *> *images = [ImageRLM objectsWhere:@"pathId CONTAINS %@", pathId];
    return images;
}

#pragma mark -- 某个文件夹下的所有图片 folderId:文件夹id 带排序
+ (RLMResults<ImageRLM *> *)allImagesAtFolder:(NSString *)folderId {
    FolderRLM *target = [LZFolderManager entityWithId:folderId];
    RLMResults<ImageRLM *> *images = [self imagesAtPath:target.pathId];
    return images;
}

#pragma mark 查询相同的图片
+ (ImageRLM *)imageRLMWithCloudUrl:(NSString *)url {
    RLMResults<ImageRLM *> *images = [ImageRLM objectsWhere:@"cloudUrl == %@",url];
    if (images.count) {
        ImageRLM *image = images.firstObject;
        return image;
    }
    return nil;
}

#pragma mark  查询某个文档中已经同步完成的图片
+ (RLMResults<ImageRLM *> *)imageRLMsSyncDoneAtDoc:(NSString *)docId {
    RLMResults<ImageRLM *> *images = [ImageRLM objectsWhere:@"parentId = %@ AND syncDone = 1",docId];
    return images;
}

#pragma mark -- 根据父id(图片上级目录id)查询images
+ (RLMResults<ImageRLM *> *)imageRLMsByParentId:(NSString *)parentId {
    RLMResults<ImageRLM *> *images = [ImageRLM objectsWhere:@"parentId = %@",parentId];
    return images;
}

#pragma mark -- 根据父id(图片上级目录id)查询images 并排序
+ (RLMResults<ImageRLM *> *)sortImageRLMsByParentId:(NSString *)parentId {
    RLMResults<ImageRLM *> *images = [self imageRLMsByParentId:parentId];
    RLMResults<ImageRLM *> *results = [LZImageManager sortResults:images bySortKey:@"picIndex"];
    return results;
}

#pragma mark -- 当前文档的图片首张图片作为封面
+ (ImageRLM *)firstImageByParentId:(NSString *)parentId {
    RLMResults<ImageRLM *> *results = [self sortImageRLMsByParentId:parentId];
    if (results.count > 0) {
        ImageRLM *firstObj = results.firstObject;
        return firstObj;
    }
    return nil;
}

+ (NSDictionary *)firstImageDicByDoc:(NSString *)docId {
    ImageRLM *firstObj = [self firstImageByParentId:docId];
    if (firstObj) {
        return [self entityToDic:firstObj];
    }
    return nil;
}

#pragma mark -- 当前文档中图片最大索引
+ (NSInteger)lastImageIndexByParentId:(NSString *)parentId {
    RLMResults<ImageRLM *> *results = [self sortImageRLMsByParentId:parentId];
    if (results.count > 0) {
        ImageRLM *lastObj = results.lastObject;
        return lastObj.picIndex;
    }
    return 0;
}

#pragma mark -- 根据ids查询images
+ (RLMResults<ImageRLM *> *)imageRLMsWithImageIds:(NSArray *)imgIds {
    RLMResults<ImageRLM *> *images = [ImageRLM objectsWhere:@"Id IN %@", imgIds];
    return images;
}

#pragma mark -- 根据ids顺序查询images
+ (NSMutableArray *)imageRLMsOrderByImageIds:(NSArray *)imgIds {
    NSMutableArray *sortImages = @[].mutableCopy;
    for (NSString *imgId in imgIds) {
        ImageRLM *target = [LZImageManager entityWithId:imgId];
        if (target) {
            [sortImages addObject:target];
        }
    }
    return sortImages;
}


#pragma mark -- 对查询结果进行排序 默认排序类型排序
+ (RLMResults *)sortResults:(RLMResults *)results {
    NSString *sortKey = [self sortRule][@"sortKey"];
    BOOL asceding = [[self sortRule][@"asceding"] boolValue];
    RLMResults *res = [results sortedResultsUsingKeyPath:sortKey ascending:asceding];
    return res;
}

#pragma mark -- 默认排序规则
+ (NSDictionary *)sortRule {
    NSInteger type = 2;//[ScanerShare sortType];
    NSString *sortKey = @"uTime";
    BOOL asceding = NO;
    switch (type) {
        case 0:
            sortKey = @"cTime";
            asceding = NO;
            break;
        case 1:
            sortKey = @"cTime";
            asceding = YES;
            break;
        case 2:
            sortKey = @"uTime";
            asceding = NO;
            break;
        case 3:
            sortKey = @"uTime";
            asceding = YES;
            break;
        case 4:
            sortKey = @"name";
            asceding = YES;
            break;
        case 5:
            sortKey = @"name";
            asceding = NO;
            break;
            
        default:
            break;
    }
    return @{@"sortKey":sortKey, @"asceding":@(asceding)};
}

+ (NSMutableArray<NSDictionary *> *)entityListToDic:(id<NSFastEnumeration>)results {
    NSMutableArray *temp = @[].mutableCopy;
    for (id<LZRLMObjectProtocol> object in results) {
        NSDictionary *dic = [self entityToDic:object];
        if (dic) {
            [temp addObject:dic];
        }
    }
    return temp;
}

+ (NSDictionary *)entityToDic:(id<LZRLMObjectProtocol>)entity {
    if (!entity) {
        return nil;
    }
    NSDictionary *dic = [entity modelToDic];
    NSMutableDictionary *temp = [dic mutableCopy];
    NSString *type = @"1";
    if ([entity isKindOfClass:[FolderRLM class]]) {
        type = @"1";
    } else if ([entity isKindOfClass:[DocRLM class]]) {
        type = @"2";
    } else {//ImageRLM
        type = @"3";
    }
    temp[@"type"] = type;
    return [NSDictionary dictionaryWithDictionary:temp];
}

@end
