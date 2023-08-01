//
//  LZFolderManager.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "LZFolderManager.h"
#import "LZDBService.h"

@implementation LZFolderManager
#pragma mark ** 查
#pragma mark -- FolderRLM 查询
+ (FolderRLM *)entityWithId:(NSString *)Id {
    FolderRLM *target = [FolderRLM objectForPrimaryKey:Id];
    return target;
}

#pragma mark -- 主键多条查询
+ (RLMResults<FolderRLM *> *)entityListWithIds:(NSArray *)ids {
    RLMResults<FolderRLM *> *results = [FolderRLM objectsWhere:@"Id IN %@", ids];
    return results;
}

#pragma mark -- FolderRLM 根据属性自定义查询
+ (FolderRLM *)entityWithProperty:(NSString *)property value:(NSString *)value {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",property, value];
    RLMResults<FolderRLM *> *resluts = [self entityListWithCondition:predicate];
    if (resluts.count) {
        return resluts.firstObject;
    }
    return nil;
}

#pragma mark -- 所有FolderRLM 不排序
+ (RLMResults<FolderRLM *> *)allEntityList {
    RLMResults<FolderRLM *> *resluts = [FolderRLM allObjects];
    return resluts;
}

//#pragma mark -- 所有FolderRLM uTime降序(默认排序)
//+ (RLMResults<FolderRLM *> *)allEntityListBySorted {
//    RLMResults<FolderRLM *> *resluts = [self defaultSortByResults:[self allEntityList]];
//    return resluts;
//}

#pragma mark -- 根据自定义条件查询
+ (RLMResults<FolderRLM *> *)entityListWithCondition:(NSPredicate *)predicate {
    RLMResults<FolderRLM *> *resluts = [FolderRLM objectsWithPredicate:predicate];
    return resluts;
}

#pragma mark -- 根据现有结果自定义条件查询
+ (RLMResults<FolderRLM *> *)entityListWithTargets:(RLMResults *)targets byCondition:(NSPredicate *)predicate {
    RLMResults<FolderRLM *> *results = [targets objectsWithPredicate:predicate];
    return results;
}


#pragma mark ** 增
#pragma mark -- 新增文件夹
+ (void)addEntity:(FolderRLM *)objRLM {
    [LZDBService saveObject:objRLM];
}

#pragma mark -- 批量新增文件夹
+ (void)batchAddEntityList:(NSArray<FolderRLM *> *)objs {
    [LZDBService saveAllObjects:objs];
}

#pragma mark ** 改
#pragma mark -- 更新文件夹
+ (void)updateEntity:(FolderRLM *)obj {
    [LZDBService addOrUpdateObject:obj];
}

#pragma mark -- 批量更新文件夹
+ (void)batchUpdateEntityInfo:(NSDictionary *)data byEntityIds:(nonnull NSArray *)objIds {
    RLMResults<FolderRLM *> *objects = [FolderRLM objectsWhere:@"Id IN %@", objIds];
    [LZDBService batchUpdateObjects:objects data:data];
}

/// 执行自定义事务，一般以修改为主
/// @param block 事务执行内容
+ (void)updateTransactionWithBlock:(void(^)(void))block {
    [LZDBService transactionWithBlock:block];
}

#pragma mark ** 删
#pragma mark -- 删除文件夹
+ (void)removeEntity:(FolderRLM *)obj {
    [LZDBService removeObject:obj];
}

+ (void)deleteEntityWithId:(NSString *)objId {
    FolderRLM *target = [self entityWithId:objId];
    [self removeEntity:target];
}

#pragma mark -- 批量删除文件夹
+ (void)removeEntityList:(id)objs {
    [LZDBService removeAllObjects:objs];
}

+ (void)batchDeleteWithEntityIds:(NSArray *)objIds {
    RLMResults<FolderRLM *> *objs = [self entityListWithIds:objIds];
    [self removeEntityList:objs];
}

@end
