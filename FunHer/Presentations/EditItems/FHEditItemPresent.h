//
//  FHEditItemPresent.h
//  FunHer
//
//  Created by GLA on 2023/9/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHEditItemPresent : NSObject
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *parentId;//父目录对象Id
@property (nonatomic, copy) NSString *selectedItem;//已经选中的对象Id
@property (nonatomic, assign) BOOL selectedAll;

///-- 刷新数据
- (void)refreshData;

- (NSArray *)funcItems;

- (void)handSelectedAll;

- (NSArray *)selectedItemArray;

/// -- 合并保留原文件
- (NSString *)mergeFiles;

/// -- 合并后删除原文件
- (NSString *)mergeFilesDeleteOldFile;

/// -- 分享
- (NSArray *)shareFiles;

/// -- 移动
/// - Parameter folderId: 文件夹id
- (void)moveFileToFolder:(NSString *)folderId;

/// -- 复制
/// - Parameter folderId: 文件夹id
- (void)copyFileToFolder:(NSString *)folderId;

/// -- 删除
- (void)deleteFiles;

@end

NS_ASSUME_NONNULL_END
