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
        [LZFolderManager addEntity:entity];
        dic = [entity modelToDic];
    }
    return dic;
}

+ (FolderRLM *)buildFolderWithName:(NSString *)name atPath:(NSString *)pathId {
    FolderRLM *entity = [[FolderRLM alloc] init];
    entity.Id = [[NSUUID UUID] UUIDString];
    entity.parentId = [pathId fileName];
    entity.name = name;
    entity.pathId = [pathId stringByAppendingPathComponent:name];
    entity.cTime = [[NSDate date] timeIntervalSince1970];
    entity.uTime = [[NSDate date] timeIntervalSince1970];
    
    return entity;
}

#pragma mark ** 文档


#pragma mark ** 图片

@end
