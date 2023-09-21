//
//  FHLibraryCommand.m
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import "FHLibraryCommand.h"
#import "FHFirebaseCoreManager.h"

@implementation FHLibraryCommand

- (void)execute {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    [FHFirebaseCoreManager configure];//放在最前面
    [LZFileManager removeItemAtPath:[NSString imageTempBox]];
}

@end
