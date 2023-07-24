//
//  LZNetWorkManager.h
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZNetWorkManager : NSObject

/// post 请求
+(void)postRequestWithUrl:(NSString *)url Param:(NSDictionary *)param
                  success:(void (^)(NSDictionary * res))success
                  failure:(void (^)(NSError *error))failure;
  
/// get 请求
+(void)getRequestWithUrl:(NSString *)url Param:(NSDictionary *)param
                 success:(void (^)(NSDictionary * res))success
                 failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
