//
//  NSString+Format.h
//  FunHer
//
//  Created by GLA on 2023/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Format)

+ (NSString *)memorySizeFormat:(float)totalSize;

@end

NS_ASSUME_NONNULL_END
