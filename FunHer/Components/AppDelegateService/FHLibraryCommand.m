//
//  FHLibraryCommand.m
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import "FHLibraryCommand.h"

@implementation FHLibraryCommand

- (void)execute {
    [LZFileManager removeItemAtPath:[NSString imageTempBox]];
    NSLog(@"library");
}

@end
