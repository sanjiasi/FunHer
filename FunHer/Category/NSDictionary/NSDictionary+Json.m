//
//  NSDictionary+Json.m
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import "NSDictionary+Json.h"

@implementation NSDictionary (Json)

#pragma mark -- 转JSON字符串
- (NSString *)toJsonStr {
    NSDictionary *dic = self;
    if (dic.allKeys.count) {
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return @"";
}

@end
