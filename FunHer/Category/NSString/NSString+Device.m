//
//  NSString+Device.m
//  FunHer
//
//  Created by GLA on 2023/9/11.
//

#import "NSString+Device.h"
#import "sys/utsname.h"

@implementation NSString (Device)

+ (NSString *)deviceVersion {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}

+ (NSString*)systemVersion {
    NSString *str = [NSString stringWithFormat:@"IOS:%.2f",[[[UIDevice currentDevice] systemVersion] floatValue]];
    return str;
}

+ (NSString *)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)appBundleId {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

@end
