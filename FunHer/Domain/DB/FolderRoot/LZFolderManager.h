//
//  LZFolderManager.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Foundation/Foundation.h>
#import "FolderRLM.h"

NS_ASSUME_NONNULL_BEGIN

@interface LZFolderManager : NSObject
/// FolderRLM 查询
/// @param Id  主键
+ (FolderRLM *)entityWithId:(NSString *)Id;

/// 主键多条查询
/// @param ids  主键
+ (RLMResults<FolderRLM *> *)entityListWithIds:(NSArray *)ids;

/// FolderRLM 根据属性自定义查询
/// @param property  字段
/// @param value  值
+ (FolderRLM *)entityWithProperty:(NSString *)property value:(NSString *)value;

/// 所有数据对象 不排序
+ (RLMResults<FolderRLM *> *)allEntityList;

/// 所有数据对象 uTime降序
+ (RLMResults<FolderRLM *> *)allEntityListBySorted;

/// 根据自定义条件查询
/// - Parameter predicate: 谓词搜索
+ (RLMResults<FolderRLM *> *)entityListWithCondition:(NSPredicate *)predicate;

/// 根据现有结果自定义条件查询
/// @param targets 结果
/// @param predicate 谓词
+ (RLMResults<FolderRLM *> *)entityListWithTargets:(RLMResults<FolderRLM *> *)targets byCondition:(NSPredicate *)predicate;

/// 默认uTime降序
/// - Parameter results: 上一阶段的查询结果
+ (RLMResults *)defaultSortByResults:(RLMResults *)results;

#pragma mark -- 增
/// 添加FolderRLM
/// @param objRLM  数据对象
+ (void)addEntity:(FolderRLM *)objRLM;

/// 批量添加FolderRLM
/// @param objs  多个FolderRLM
+ (void)batchAddEntityList:(NSArray<FolderRLM *> *)objs;

#pragma mark -- 改
/// 更新FolderRLM
/// @param obj  实体对象
+ (void)updateEntity:(FolderRLM *)obj;

/// 批量更新FolderRLM
/// @param data 修改数据
/// @param objIds 修改对象
+ (void)batchUpdateEntityInfo:(NSDictionary *)data byEntityIds:(nonnull NSArray *)objIds;

/// 执行自定义事务，一般以修改为主
/// @param block 事务执行内容
+ (void)updateTransactionWithBlock:(void(^)(void))block;

#pragma mark -- 删
/// 删除FolderRLM
/// @param objId 主键
+ (void)deleteEntityWithId:(NSString *)objId;
/// 批量删除FolderRLM
/// @param objIds  主键
+ (void)batchDeleteWithEntityIds:(NSArray *)objIds;

@end

NS_ASSUME_NONNULL_END
