//
//  FHFileChildListPresent.h
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFileChildListPresent : NSObject

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *fileObjId;//文件夹主键id

/// 刷新数据
- (void)refreshData;

/// 解析图片
- (void)anialysisAssets:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion;

/// 新建文件夹
/// - Parameter name: 名称
- (void)createFolderWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
