//
//  FHModelProtocol.h
//  FunHer
//
//  Created by GLA on 2023/8/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHModelProtocol <NSObject>
/// 字典转模型
/// @param param  属性
+ (instancetype)createModelWithParam:(NSDictionary *)param;

/// 模型转字典
- (NSDictionary *)modelToDic;

@end

NS_ASSUME_NONNULL_END
