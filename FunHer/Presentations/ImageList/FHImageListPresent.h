//
//  FHImageListPresent.h
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHImageListPresent : NSObject

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *fileObjId;//文件主键id

/// 刷新数据
- (void)refreshData;

/// 解析图片
- (void)anialysisAssets:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion;

/// 新增处理后的图片
/// - Parameter info: 图片数据
- (NSDictionary *)createImage:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
