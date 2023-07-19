//
//  NSString+Encrypt.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Encrypt)

/// one-way hash 单向散列
- (NSString *)hashedValue;

/// 对一个字符串进行base64编码
- (NSString *)base64Encoded;

/// md5 加密
- (NSString *)md5Str;

@end

NS_ASSUME_NONNULL_END
