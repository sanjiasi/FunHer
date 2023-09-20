//
//  FHFirebaseCoreManager.h
//  FunHer
//
//  Created by GLA on 2023/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFirebaseCoreManager : NSObject

/// -- firebase初始化 必须放在最前面
+ (void)configure;

@end

NS_ASSUME_NONNULL_END
