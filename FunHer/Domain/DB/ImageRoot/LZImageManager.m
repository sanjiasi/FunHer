//
//  LZImageManager.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "LZImageManager.h"
#import "LZDBService.h"

@implementation LZImageManager
#pragma mark ** 查
#pragma mark -- ImageRLM 查询
+ (ImageRLM *)entityWithId:(NSString *)Id {
    ImageRLM *target = [ImageRLM objectForPrimaryKey:Id];
    return target;
}

#pragma mark -- 主键多条查询
+ (RLMResults<ImageRLM *> *)entityListWithIds:(NSArray *)ids {
    RLMResults<ImageRLM *> *results = [ImageRLM objectsWhere:@"Id IN %@", ids];
    return results;
}

#pragma mark -- ImageRLM 根据属性自定义查询
+ (ImageRLM *)entityWithProperty:(NSString *)property value:(NSString *)value {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",property, value];
    RLMResults<ImageRLM *> *resluts = [self entityListWithCondition:predicate];
    if (resluts.count) {
        return resluts.firstObject;
    }
    return nil;
}

#pragma mark -- 所有ImageRLM 不排序
+ (RLMResults<ImageRLM *> *)allEntityList {
    RLMResults<ImageRLM *> *resluts = [ImageRLM allObjects];
    return resluts;
}

#pragma mark -- 根据自定义条件查询
+ (RLMResults<ImageRLM *> *)entityListWithCondition:(NSPredicate *)predicate {
    RLMResults<ImageRLM *> *resluts = [ImageRLM objectsWithPredicate:predicate];
    return resluts;
}

#pragma mark -- 根据现有结果自定义条件查询
+ (RLMResults<ImageRLM *> *)entityListWithTargets:(RLMResults *)targets byCondition:(NSPredicate *)predicate {
    RLMResults<ImageRLM *> *results = [targets objectsWithPredicate:predicate];
    return results;
}


#pragma mark -- 对查询结果进行排序 默认升序
+ (RLMResults *)sortResults:(RLMResults *)results bySortKey:(NSString *)sortKey  {
    BOOL ascending = YES;
    RLMResults *res = [results sortedResultsUsingKeyPath:sortKey ascending:ascending];
    return res;
}


#pragma mark ** 增
#pragma mark -- 新增文档
+ (void)addEntity:(ImageRLM *)objRLM {
    [LZDBService saveObject:objRLM];
}

#pragma mark -- 批量新增文档
+ (void)batchAddEntityList:(NSArray<ImageRLM *> *)objs {
    [LZDBService saveAllObjects:objs];
}

#pragma mark ** 改
#pragma mark -- 更新文档
+ (void)updateEntity:(ImageRLM *)obj {
    [LZDBService addOrUpdateObject:obj];
}

#pragma mark -- 批量更新文档
+ (void)batchUpdateEntityInfo:(NSDictionary *)data byEntityIds:(nonnull NSArray *)objIds {
    RLMResults<ImageRLM *> *objects = [ImageRLM objectsWhere:@"Id IN %@", objIds];
    [LZDBService batchUpdateObjects:objects data:data];
}

/// 执行自定义事务，一般以修改为主
/// @param block 事务执行内容
+ (void)updateTransactionWithBlock:(void(^)(void))block {
    [LZDBService transactionWithBlock:block];
}

#pragma mark ** 删
#pragma mark -- 删除文档
+ (void)removeEntity:(id)obj {
    [LZDBService removeObject:obj];
}

+ (void)deleteEntityWithId:(NSString *)objId {
    ImageRLM *target = [self entityWithId:objId];
    [self removeEntity:target];
}

#pragma mark -- 批量删除文档
+ (void)removeEntityList:(id)objs {
    [LZDBService removeAllObjects:objs];
}

+ (void)batchDeleteWithEntityIds:(NSArray *)objIds  {
    RLMResults<ImageRLM *> *objs = [self entityListWithIds:objIds];
    [self removeEntityList:objs];
}

@end
