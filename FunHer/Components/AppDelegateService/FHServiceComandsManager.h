//
//  FHServiceComandsManager.h
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import <Foundation/Foundation.h>
#import "FHServiceCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHServiceComandsManager : NSObject

+ (NSArray<id<FHServiceCommand>> *)configurations;

@end

NS_ASSUME_NONNULL_END
