//
//  FHFileDataSession.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFileDataSession : NSObject

/// ** 文件夹
/// -- 增加文件夹
///   - name:  文件夹名
///   - parentId: 上级目录id
+ (NSDictionary *)addFolder:(NSString *)name atParent:(NSString *)parentId;

/// -- 删除文件夹
/// - Parameter objId: 主键
+ (void)deleteFolderWithId:(NSString *)objId;

/// ** 文档


/// ** 图片

@end

NS_ASSUME_NONNULL_END
