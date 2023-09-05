//
//  FHPDFTool.h
//  FunHer
//
//  Created by GLA on 2023/9/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHPDFTool : NSObject

+ (NSArray *)splitPDF:(NSURL *)url;

/// 拆分PDF保存图片到指定目录
/// - Parameters:
///   - url: PDF路径
///   - path: 保存目录
+ (NSArray *)splitPDF:(NSURL *)url atDoc:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
