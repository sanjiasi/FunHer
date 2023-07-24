//
//  LZDocManager.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "LZDocManager.h"
#import "LZDBService.h"

@implementation LZDocManager
#pragma mark ** 查
#pragma mark -- DocRLM 查询
+ (DocRLM *)entityWithId:(NSString *)Id {
    DocRLM *target = [DocRLM objectForPrimaryKey:Id];
    return target;
}

#pragma mark -- 主键多条查询
+ (RLMResults<DocRLM *> *)entityListWithIds:(NSArray *)ids {
    RLMResults<DocRLM *> *results = [DocRLM objectsWhere:@"Id IN %@", ids];
    return results;
}

#pragma mark -- DocRLM 根据属性自定义查询
+ (DocRLM *)entityWithProperty:(NSString *)property value:(NSString *)value {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",property, value];
    RLMResults<DocRLM *> *resluts = [self entityListWithCondition:predicate];
    if (resluts.count) {
        return resluts.firstObject;
    }
    return nil;
}

#pragma mark -- 所有DocRLM 不排序
+ (RLMResults<DocRLM *> *)allEntityList {
    RLMResults<DocRLM *> *resluts = [DocRLM allObjects];
    return resluts;
}

#pragma mark -- 所有DocRLM uTime降序(默认排序)
+ (RLMResults<DocRLM *> *)allEntityListBySorted {
    RLMResults<DocRLM *> *resluts = [self defaultSortByResults:[self allEntityList]];
    return resluts;
}

#pragma mark -- 根据自定义条件查询
+ (RLMResults<DocRLM *> *)entityListWithCondition:(NSPredicate *)predicate {
    RLMResults<DocRLM *> *resluts = [DocRLM objectsWithPredicate:predicate];
    return resluts;
}

#pragma mark -- 根据现有结果自定义条件查询
+ (RLMResults<DocRLM *> *)entityListWithTargets:(RLMResults *)targets byCondition:(NSPredicate *)predicate {
    RLMResults<DocRLM *> *results = [targets objectsWithPredicate:predicate];
    return results;
}

#pragma mark --  默认uTime(更新时间)降序
+ (RLMResults *)defaultSortByResults:(RLMResults *)results {
    return [results sortedResultsUsingKeyPath:@"uTime" ascending:NO];
}

#pragma mark ** 增
#pragma mark -- 新增文档
+ (void)addEntity:(DocRLM *)objRLM {
    [LZDBService saveObject:objRLM];
}

#pragma mark -- 批量新增文档
+ (void)batchAddEntityList:(NSArray<DocRLM *> *)objs {
    [LZDBService saveAllObjects:objs];
}

#pragma mark ** 改
#pragma mark -- 更新文档
+ (void)updateEntity:(DocRLM *)obj {
    [LZDBService addOrUpdateObject:obj];
}

#pragma mark -- 批量更新文档
+ (void)batchUpdateEntityInfo:(NSDictionary *)data byEntityIds:(nonnull NSArray *)objIds {
    RLMResults<DocRLM *> *objects = [DocRLM objectsWhere:@"Id IN %@", objIds];
    [LZDBService batchUpdateObjects:objects data:data];
}

/// 执行自定义事务，一般以修改为主
/// @param block 事务执行内容
+ (void)updateTransactionWithBlock:(void(^)(void))block {
    [LZDBService transactionWithBlock:block];
}

#pragma mark ** 删
#pragma mark -- 删除文档
+ (void)deleteEntityWithId:(NSString *)objId {
    DocRLM *target = [self entityWithId:objId];
    [LZDBService removeObject:target];
}

#pragma mark -- 批量删除文档
+ (void)batchDeleteWithEntityIds:(NSArray *)objIds  {
    RLMResults<DocRLM *> *objs = [self entityListWithIds:objIds];
    [LZDBService removeAllObjects:objs];
}

@end
