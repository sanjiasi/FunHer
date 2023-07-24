//
//  LZNetWorkManager.m
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import "LZNetWorkManager.h"
#import <AFNetworking/AFNetworking.h>

#define SSRequestTimeoutInterval 60.0

static NSString *prodUrlDomain = @"https://funher.gla.pro";//pro
static NSString *testUrlDomain = @"https://funher.gla.test";//test

@implementation LZNetWorkManager

#pragma mark -- 检测主工程当前环境
+ (NSString *)checkEnvironment {
    NSInteger envi = 1;
    NSString *urlDomain = envi == 1 ? prodUrlDomain : testUrlDomain;
    return urlDomain;
}

+ (void)postRequestWithUrl:(NSString *)url Param:(NSDictionary *)param success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSString *requestUrl = [self wholeRequestUrlWithPath:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:requestUrl parameters:param headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSInteger respenseCode = [[NSString stringWithFormat:@"%@",JSON[@"resultCode"]] integerValue];
        if (respenseCode == 200) {
            if ([JSON[@"data"] isKindOfClass:[NSDictionary class]]) {
                if (success) {
                    success(JSON[@"data"]);
                }
            } else {
                if (success) {
                    success(JSON);
                }
            }
        } else {
            if (failure) {
                NSError * newError = [[NSError alloc]initWithDomain:@"vip.service.error" code:[JSON[@"resultCode"] integerValue] userInfo:@{NSLocalizedDescriptionKey :  JSON[@"errorMessage"], @"statusCode": [NSString stringWithFormat:@"%@", JSON[@"resultCode"]]}];
                failure(newError);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            NSHTTPURLResponse * reponse = (NSHTTPURLResponse *)task.response;
            NSError * newError = [self definNewWorkErrorWithError:error statusCode:reponse.statusCode];
            failure(error);
        }
    }];
}

+ (void)getRequestWithUrl:(NSString *)url Param:(NSDictionary *)param success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSString *requestUrl = [self wholeRequestUrlWithPath:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:requestUrl parameters:param headers:@{} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSInteger respenseCode = [[NSString stringWithFormat:@"%@",JSON[@"status"]] integerValue];
        if (respenseCode == 200) {
            if ([JSON[@"data"] isKindOfClass:[NSDictionary class]]) {
                if (success) {
                    success(JSON[@"data"]);
                }
            } else {
                if (success) {
                    success(JSON);
                }
            }
        } else {
            if (failure) {
                NSError * newError = [[NSError alloc]initWithDomain:@"vip.service.error" code:[JSON[@"resultCode"] integerValue] userInfo:@{NSLocalizedDescriptionKey :  JSON[@"errorMessage"], @"statusCode": [NSString stringWithFormat:@"%@", JSON[@"resultCode"]]}];
                failure(newError);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            NSHTTPURLResponse * reponse = (NSHTTPURLResponse *)task.response;
            NSError * newError = [self definNewWorkErrorWithError:error statusCode:reponse.statusCode];
            failure(newError);
        }
    }];
}

#pragma mark - Private
//请求地址拼接
+ (NSString *)wholeRequestUrlWithPath:(NSString *)urlPath {
    if ([urlPath hasPrefix:@"http"]) {
        return urlPath;
    }
    NSString *domainStr = [self checkEnvironment];
    if ([urlPath hasPrefix:@"/"]) {
        return [NSString stringWithFormat:@"%@%@",domainStr,urlPath];
    }
    else
        return [NSString stringWithFormat:@"%@/%@",domainStr,urlPath];
}

+ (NSError *)definNewWorkErrorWithError:(NSError *)error statusCode:(NSInteger)code {
    NSString * msg = @"";
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (errorData) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableLeaves error:&error];
        if ([jsonData isKindOfClass:[NSDictionary class]]) {
            NSDictionary * resDic = (NSDictionary *)jsonData;
            msg = [resDic objectForKey:@"msg"];
            
        }
    }
    //code = -1001 表示网络超时
    if (!msg.length && (error.code == -1001)) {
        msg = @"timeout";
    }
    //statusCode是的http返回的状态码 比如请求超时-1001等
    return [[NSError alloc]initWithDomain:@"vip.service.error" code:code userInfo:@{NSLocalizedDescriptionKey : msg, @"statusCode": [NSString stringWithFormat:@"%ld", error.code]}];
}

@end
