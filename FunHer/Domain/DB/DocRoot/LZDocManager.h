//
//  LZDocManager.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Foundation/Foundation.h>
#import "DocRLM.h"

NS_ASSUME_NONNULL_BEGIN

@interface LZDocManager : NSObject
/// DocRLM 查询
/// @param Id  主键
+ (DocRLM *)entityWithId:(NSString *)Id;

/// 主键多条查询
/// @param ids  主键
+ (RLMResults<DocRLM *> *)entityListWithIds:(NSArray *)ids;

/// DocRLM 根据属性自定义查询
/// @param property  字段
/// @param value  值
+ (DocRLM *)entityWithProperty:(NSString *)property value:(NSString *)value;

/// 所有数据对象 不排序
+ (RLMResults<DocRLM *> *)allEntityList;


/// 根据自定义条件查询
/// - Parameter predicate: 谓词搜索
+ (RLMResults<DocRLM *> *)entityListWithCondition:(NSPredicate *)predicate;

/// 根据现有结果自定义条件查询
/// @param targets 结果
/// @param predicate 谓词
+ (RLMResults<DocRLM *> *)entityListWithTargets:(RLMResults<DocRLM *> *)targets byCondition:(NSPredicate *)predicate;


#pragma mark -- 增
/// 添加DocRLM
/// @param objRLM  数据对象
+ (void)addEntity:(DocRLM *)objRLM;

/// 批量添加DocRLM
/// @param objs  多个DocRLM
+ (void)batchAddEntityList:(NSArray<DocRLM *> *)objs;

#pragma mark -- 改
/// 更新DocRLM
/// @param obj  实体对象
+ (void)updateEntity:(DocRLM *)obj;

/// 批量更新DocRLM
/// @param data 修改数据
/// @param objIds 修改对象
+ (void)batchUpdateEntityInfo:(NSDictionary *)data byEntityIds:(nonnull NSArray *)objIds;

/// 执行自定义事务，一般以修改为主
/// @param block 事务执行内容
+ (void)updateTransactionWithBlock:(void(^)(void))block;

#pragma mark -- 删
/// 删除DocRLM
/// @param obj  实体
+ (void)removeEntity:(DocRLM *)obj;

/// 批量删除DocRLM
/// @param objs  实体数组
+ (void)removeEntityList:(id)objs;

/// 删除DocRLM
/// @param objId 主键
+ (void)deleteEntityWithId:(NSString *)objId;

/// 批量删除DocRLM
/// @param objIds  主键
+ (void)batchDeleteWithEntityIds:(NSArray *)objIds;

@end

NS_ASSUME_NONNULL_END
