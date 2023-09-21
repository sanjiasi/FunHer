//
//  NSString+Json.m
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import "NSString+Json.h"

@implementation NSString (Json)

#pragma mark - 字符串转字典
- (NSDictionary *)toDictionary {
    NSString *jsonString = self;
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        DELog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - 字符串转数组
- (NSArray *)toArray {
    NSString *jsonString = self;
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&err];
    if(err) {
        DELog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}

@end
