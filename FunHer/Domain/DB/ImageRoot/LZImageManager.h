//
//  LZImageManager.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Foundation/Foundation.h>
#import "ImageRLM.h"

NS_ASSUME_NONNULL_BEGIN

@interface LZImageManager : NSObject

#pragma mark -- 查
/// ImageRLM 查询
/// @param Id  主键
+ (ImageRLM *)entityWithId:(NSString *)Id;

/// 主键多条查询
/// @param ids  主键
+ (RLMResults<ImageRLM *> *)entityListWithIds:(NSArray *)ids;

/// ImageRLM 根据属性自定义查询
/// @param property  字段
/// @param value  值
+ (ImageRLM *)entityWithProperty:(NSString *)property value:(NSString *)value;

/// 所有数据对象 不排序
+ (RLMResults<ImageRLM *> *)allEntityList;

/// 所有数据对象 uTime降序
+ (RLMResults<ImageRLM *> *)allEntityListBySorted;

/// 根据自定义条件查询
/// - Parameter predicate: 谓词搜索
+ (RLMResults<ImageRLM *> *)entityListWithCondition:(NSPredicate *)predicate;

/// 根据现有结果自定义条件查询
/// @param targets 结果
/// @param predicate 谓词
+ (RLMResults<ImageRLM *> *)entityListWithTargets:(RLMResults<ImageRLM *> *)targets byCondition:(NSPredicate *)predicate;

/// 默认uTime降序
/// - Parameter results: 上一阶段的查询结果
+ (RLMResults *)defaultSortByResults:(RLMResults *)results;

#pragma mark -- 增
/// 添加ImageRLM
/// @param objRLM  数据对象
+ (void)addEntity:(ImageRLM *)objRLM;

/// 批量添加ImageRLM
/// @param objs  多个ImageRLM
+ (void)batchAddEntityList:(NSArray<ImageRLM *> *)objs;

#pragma mark -- 改
/// 更新ImageRLM
/// @param obj  实体对象
+ (void)updateEntity:(ImageRLM *)obj;

/// 批量更新ImageRLM
/// @param data 修改数据
/// @param objIds 修改对象
+ (void)batchUpdateEntityInfo:(NSDictionary *)data byEntityIds:(nonnull NSArray *)objIds;

/// 执行自定义事务，一般以修改为主
/// @param block 事务执行内容
+ (void)updateTransactionWithBlock:(void(^)(void))block;

#pragma mark -- 删
/// 删除ImageRLM
/// @param obj  实体
+ (void)removeEntity:(ImageRLM *)obj;

/// 批量删除ImageRLM
/// @param objs  实体数组
+ (void)removeEntityList:(id)objs;

/// 删除ImageRLM
/// @param objId 主键
+ (void)deleteEntityWithId:(NSString *)objId;

/// 批量删除ImageRLM
/// @param objIds  主键
+ (void)batchDeleteWithEntityIds:(NSArray *)objIds;

@end

NS_ASSUME_NONNULL_END
