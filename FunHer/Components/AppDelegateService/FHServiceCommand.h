//
//  FHServiceCommand.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHServiceCommand <NSObject>

/// 执行命令
- (void)execute;

@end

NS_ASSUME_NONNULL_END
