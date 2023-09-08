//
//  FHFileDataSession.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFileDataSession : NSObject

#pragma mark ** 文件夹
/// -- 增加文件夹
///   - name:  文件夹名
///   - parentId: 上级目录主键iid
+ (NSDictionary *)addFolder:(NSString *)name atParent:(NSString *)parentId;

/// -- 删除文件夹
/// - Parameter objId: 主键
+ (void)deleteFolderWithId:(NSString *)objId;

/// -- 修改文件夹名称
///   - name: 文件夹名
///   - objId:  文件夹主键id
+ (void)editFolderName:(NSString *)name withId:(NSString *)objId;

/// -- 修改文件夹密码
///   - password: 密码
///   - objId: 文件夹主键id
+ (void)editFolderPassword:(NSString *)password withId:(NSString *)objId;

/// -- 修改文件夹路径：移动
///   - objId: 文件夹主键id
///   - parentId: 上层目录主键iId
+ (void)editFolderPath:(NSString *)objId withParentId:(NSString *)parentId;

/// -- 根据parentId获取上层目录的pathId
+ (NSString *)pathIdByParentId:(NSString *)parentId;

/// -- 拷贝文件夹：（生成一份新数据，不删除老数据）
///   - objId: 文件夹主键id
///   - parentId: 上层目录Id
+ (void)copyFolder:(NSString *)objId withParentId:(NSString *)parentId;


/// -- 批量修改文件夹
///   - folderIds: 文件夹主键ids
///   - data:  更新内容
+ (void)batchUpdateFolders:(NSArray *)folderIds withData:(NSDictionary *)data;

/// ** 文档
/// -- 增加文档
///   - name:  文档名
///   - parentId: 上层目录主键iId
+ (NSDictionary *)addDocument:(NSString *)name withParentId:(NSString *)parentId;

/// -- 删除文档
+ (void)deleteDocumentWithId:(NSString *)objId;

/// -- 修改文档名称
///   - name:  文档名
///   - objId: 文档主键Id
+ (void)editDocumentName:(NSString *)name withId:(NSString *)objId;

/// -- 修改文档密码
///   - password: 密码
///   - objId: 文档主键Id
+ (void)editDocumentPassword:(NSString *)password withId:(NSString *)objId;

///  -- 修改文档浏览时间
/// - Parameter objId: 文档主键Id
+ (void)editDocumentReadingTimeWithId:(NSString *)objId;

/// -- 修改文档路径：移动
///   - objId: 文档主键Id
///   - parentId: 上层目录主键iId
+ (void)editDocumentPath:(NSString *)objId withParentId:(NSString *)parentId;

/// -- 拷贝文档 返回新文档Id
///   - objId: 文档主键Id
///   - parentId:  上层目录主键iId
+ (NSString *)copyDocument:(NSString *)objId withParentId:(NSString *)parentId;


#pragma mark ** 图片
/// -- 新增图片
///   - name: 图片名
///   - index: 索引 用于排序
///   - parentId: 上层目录Id(文档主键Id)
+ (NSDictionary *)addImage:(NSString *)name byIndex:(NSInteger)index withParentId:(NSString *)parentId;

/// -- 删除图片
+ (void)deleteImageWithId:(NSString *)objId;

/// -- 更新图片
/// - Parameter objId: 图片主键Id
+ (void)updateImageWithId:(NSString *)objId;

/// -- 批量修改图片路径：移动 文档的所有图片
///   - parentId: 上层目录Id(文档主键Id)
///   - newDocId:  移动目标文档主键Id
+ (NSArray *)batchMoveImagesWithParentId:(NSString *)parentId toNewDoc:(NSString *)newDocId;

/// -- 批量移动图片 文档的部分图片 修改parentId、pathId、picIndex
///   - imageIds:  图片主键Ids
///   - newDocId: 移动目标文档主键Id
+ (NSArray *)batchMoveImageWithIds:(NSArray *)imageIds toNewDoc:(NSString *)newDocId;

/// -- 批量复制文档的所有图片
///   - parentId: 上层目录Id(文档主键Id)
///   - newDocId: 复制目标文档主键Id
+ (NSArray *)batchCopytImagesAtParentId:(NSString *)parentId toNewDoc:(NSString *)newDocId;

/// -- 批量复制图片 修改parentId、pathId、picIndex
///   - imageIds:  图片主键Ids
///   - newDocId:  复制目标文档主键Id
+ (NSArray *)batchCopyImageWithIds:(NSArray *)imageIds toNewDoc:(NSString *)newDocId;


@end

NS_ASSUME_NONNULL_END
