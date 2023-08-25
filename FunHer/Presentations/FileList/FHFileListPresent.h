//
//  FHFileListPresent.h
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ListPresentDelegate <NSObject>

@optional

- (void)selectItemCount:(NSString *)num indexPath:(NSIndexPath *)indexPath;

@end

@interface FHFileListPresent : NSObject<ListPresentDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak) id<ListPresentDelegate> delegate;

/// 刷新数据
- (void)refreshData;

/// 解析图片
- (void)anialysisAssets:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion;

/// 新建文件夹
/// - Parameter name: 名称
- (void)createFolderWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
