//
//  FHReadFileSession.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "LZRLMObjectProtocol.h"

@class FolderRLM, DocRLM, ImageRLM;
NS_ASSUME_NONNULL_BEGIN

@interface FHReadFileSession : NSObject
#pragma mark -- 文件夹
/// -- 根据父id(文件夹上级目录id)查询folders 默认排序
+ (RLMResults<FolderRLM *> *)foldersByParentId:(NSString *)parentId;

/// -- 查询首页的文件夹 
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

/// 默认uTime降序
/// - Parameter results: 上一阶段的查询结果
+ (RLMResults *)defaultSortByResults:(RLMResults *)results;

#pragma mark -- 文档
/// 文件夹内的文档(非首页的文档)
+ (RLMResults<DocRLM *> *)allDocumentsAtFoler;

/// -- 查询所有的文档 最近浏览时间排序
+ (RLMResults<DocRLM *> *)allDocumentsByRecent;

/// -- 根据父id(文档上级目录id)查询documents 默认排序
+ (RLMResults<DocRLM *> *)documentsByParentId:(NSString *)parentId;

/// -- 查询首页的文档 默认排序
+ (RLMResults<DocRLM *> *)homeDocumentsBySorted;

/// -- 查询某个文件夹下的所有文档 可用于计数
+ (RLMResults<DocRLM *> *)documentsAtFoler:(NSString *)folderId;

/// - 统计某个文件夹下的所有文档个数
/// - Parameter folderId:
+ (NSInteger)docCountAtFolder:(NSString *)folderId;

#pragma mark -- 图片
/// -- 根据图片名称和父id(图片上级目录id)查询images
+ (RLMResults<ImageRLM *> *)imageRLMsByParentId:(NSString *)parentId withName:(NSString *)name;

/// -- 计数某个目录下的所有图片个数 pathId:路径id
+ (RLMResults<ImageRLM *> *)imagesAtPath:(NSString *)pathId;

/// -- 某个文件夹下的所有图片 folderId:文件夹id 带排序
+ (RLMResults<ImageRLM *> *)allImagesAtFolder:(NSString *)folderId;

/// 查询相同的图片
+ (ImageRLM *)imageRLMWithCloudUrl:(NSString *)url;

///  查询某个文档中已经同步完成的图片
+ (RLMResults<ImageRLM *> *)imageRLMsSyncDoneAtDoc:(NSString *)docId;

/// -- 根据父id(图片上级目录id)查询images
+ (RLMResults<ImageRLM *> *)imageRLMsByParentId:(NSString *)parentId;

/// -- 根据父id(图片上级目录id)查询images 并排序
+ (RLMResults<ImageRLM *> *)sortImageRLMsByParentId:(NSString *)parentId;

/// -- 当前文档的图片首张图片作为封面
+ (ImageRLM * _Nullable)firstImageByParentId:(NSString *)parentId;

+ (NSDictionary *)firstImageDicByDoc:(NSString *)docId;

/// -- 当前文档中图片最大索引
+ (NSInteger)lastImageIndexByParentId:(NSString *)parentId;

/// -- 当前文档的图片数量
+ (NSInteger)imageCountAtDoc:(NSString *)docId;

/// -- 根据ids查询images
+ (RLMResults<ImageRLM *> *)imageRLMsWithImageIds:(NSArray *)imgIds;

/// -- 根据ids顺序查询images
+ (NSMutableArray *)imageRLMsOrderByImageIds:(NSArray *)imgIds;

/// 批量处理-数据库对象转模型
/// - Parameter results: 查询结果
+ (NSMutableArray<NSDictionary *> *)entityListToDic:(id<NSFastEnumeration>)results;

/// 数据库对象转模型
/// - Parameter entity: 数据库对象
+ (NSDictionary *)entityToDic:(id<LZRLMObjectProtocol> _Nullable)entity;

@end

NS_ASSUME_NONNULL_END
