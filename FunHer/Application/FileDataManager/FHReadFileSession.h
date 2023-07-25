//
//  FHReadFileSession.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@class FolderRLM;
NS_ASSUME_NONNULL_BEGIN

@interface FHReadFileSession : NSObject
#pragma mark -- 文件夹
/// -- 根据父id(文件夹上级目录id)查询folders 默认排序
+ (RLMResults<FolderRLM *> *)foldersByParentId:(NSString *)parentId;

/// -- 查询首页的文件夹 默认排序
+ (RLMResults<FolderRLM *> *)homeFoldersBySorted;

/// -- 查询某个文件夹下的所有folder 可用于计数
+ (RLMResults<FolderRLM *> *)foldersAtFile:(NSString *)folderId;

/// -- 查询所有的文件夹 根据第一级目录排序：用于复制、移动的文件夹数据
+ (NSMutableArray *)allFoldersByFatherDirectorySorted;

/// -- 先加第一层的第一个文件及其所有子文件，后加第二个文件及其所有 -- 类推 01, 01/101, 02, 02/102
+ (NSMutableArray *)foldersByDocId:(NSString *)docId data:(NSMutableArray *)allData;

/// -- 查询所有的文件夹 根据目录排序
+ (NSMutableArray *)allFoldersByDirectorySorted;

/// -- 先加第一层全部，后加第一层文件的子文件 -- 类推 01, 02, 01/101, 02/102
+ (NSMutableArray *)foldersByParentId:(NSString *)parentId data:(NSMutableArray *)allData;

@end

NS_ASSUME_NONNULL_END
