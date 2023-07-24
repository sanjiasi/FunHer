//
//  LZRLMObjectProtocol.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LZRLMObjectProtocol <NSObject>

/// 构造数据库模型
/// @param param  属性
+ (instancetype)createRLMObjWithParam:(NSDictionary *)param;

/// 模型转字典
- (NSDictionary *)modelToDic;

@end

NS_ASSUME_NONNULL_END
