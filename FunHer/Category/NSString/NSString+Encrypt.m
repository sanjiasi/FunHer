//
//  NSString+Encrypt.m
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import "NSString+Encrypt.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Encrypt)

#pragma mark -- one-way hash 单向散列
- (NSString *)hashedValue {
    NSString *userAccountName = self;
    const int HASH_SIZE = CC_SHA256_DIGEST_LENGTH;
    unsigned char hashedChars[HASH_SIZE];
    const char *accountName = [userAccountName UTF8String];
    size_t accountNameLen = strlen(accountName);
 
    // Confirm that the length of the user name is small enough
    // to be recast when calling the hash function.
    if (accountNameLen > UINT32_MAX) {
        NSLog(@"Account name too long to hash: %@", userAccountName);
        return nil;
    }
    CC_SHA256(accountName, (CC_LONG)accountNameLen, hashedChars);
 
    // Convert the array of bytes into a string showing its hex representation.
    NSMutableString *userAccountHash = [[NSMutableString alloc] init];
    for (int i = 0; i < HASH_SIZE; i++) {
        // Add a dash every four bytes, for readability.
        if (i != 0 && i%4 == 0) {
            [userAccountHash appendString:@"-"];
        }
        [userAccountHash appendFormat:@"%02x", hashedChars[i]];
    }
    return userAccountHash;
}

#pragma mark -对一个字符串进行base64编码
- (NSString *)base64Encoded {
    NSString *string = self;
    //1、先转换成二进制数据
    NSData *data =[string dataUsingEncoding:NSUTF8StringEncoding];
    //2、对二进制数据进行base64编码，完成后返回字符串
    return [data base64EncodedStringWithOptions:0];
}

#pragma mark -- md5 加密
- (NSString *)md5Str {
    NSString *str = self;
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return [NSString stringWithString:digest];
}

@end
