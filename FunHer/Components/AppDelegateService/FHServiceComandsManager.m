//
//  FHServiceComandsManager.m
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import "FHServiceComandsManager.h"
#import "FHRootVCCommand.h"
#import "FHRealmDBCommand.h"
#import "FHAppearanceCommand.h"
#import "FHLibraryCommand.h"

@implementation FHServiceComandsManager

+ (NSArray<id<FHServiceCommand>> *)configurations {
    return @[[FHLibraryCommand new],
             [FHLibraryCommand new],
             [FHAppearanceCommand new],
             [FHRootVCCommand new], ];
}

@end
