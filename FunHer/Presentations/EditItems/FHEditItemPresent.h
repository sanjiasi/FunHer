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

/// 刷新数据
- (void)refreshData;

- (NSArray *)funcItems;

- (void)handSelectedAll;

- (NSArray *)selectedItemArray;

/// 合并保留原文件
- (NSString *)mergeFiles;

/// 合并后删除原文件
- (NSString *)mergeFilesDeleteOldFile;

@end

NS_ASSUME_NONNULL_END
