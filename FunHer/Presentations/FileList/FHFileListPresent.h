//
//  FHFileListPresent.h
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHFileCellModel;

@protocol ListPresentDelegate <NSObject>

@optional

- (void)selectItemCount:(NSString *)num indexPath:(NSIndexPath *)indexPath;

@end

@interface FHFileListPresent : NSObject<ListPresentDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak) id<ListPresentDelegate> delegate;
@property (nonatomic, strong) NSIndexPath * _Nullable selectedIndex;
@property (nonatomic, copy) NSString *selectedObjectId;

/// 刷新数据
- (void)refreshData;

/// 解析图片
- (void)anialysisAssets:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion;

/// 保存原图
///   - data: 图片数据
///   - size: 尺寸
///   - idx:  索引
- (NSString *)saveOriginalPhoto:(NSData *)data imageSize:(CGSize)size atIndex:(NSUInteger)idx;

/// 新建文件夹
/// - Parameter name: 名称
- (void)createFolderWithName:(NSString *)name;

/// 创建文档
/// - Parameter info: 图片信息
- (NSDictionary *)createDocWithImage:(NSDictionary *)info;

/// -- PDF拆分成images 创建文档
///   - aUrl:  pdf路径
- (NSDictionary *)getImagesFromPDF:(NSURL *)aUrl;

///  -- 处理文件中获取的资源
/// - Parameter urls: 资源路径
- (NSDictionary *)handlePickDocumentsAtURLs:(NSArray<NSURL *> *)urls;

/// 字典转界面数据模型
/// - Parameter object: 字典
- (FHFileCellModel *)buildCellModelWihtObject:(NSDictionary *)object;

- (NSArray *)funcItems;

/// 选中的文件是否可编辑
- (BOOL)canSelectedToEdit;

@end

NS_ASSUME_NONNULL_END
