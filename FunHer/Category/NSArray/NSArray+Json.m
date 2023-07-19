//
//  NSArray+Json.m
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import "NSArray+Json.h"

@implementation NSArray (Json)

#pragma mark -- 转json字符串
- (NSString *)toJsonStr {
    NSArray *arr = self;
    if (arr.count) {
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:&parseError];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return @"";
}

@end
