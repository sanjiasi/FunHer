//
//  FHFilterImagePresent.h
//  FunHer
//
//  Created by GLA on 2023/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFilterImagePresent : NSObject
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileObjId;//文件主键id
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger selectdIndex;
@property (nonatomic, copy) NSString *cropImgPath;//裁剪后的图片
@property (nonatomic, copy) NSString *filterImage;//滤镜处理后的图片

/// 刷新数据
- (void)refreshData;

/// 选择滤镜
- (void)didSelected:(NSInteger)indx;

/// 右转
- (void)rotateImageByRight;

/// 创建文档
- (void)createDocWithImage;

@end

NS_ASSUME_NONNULL_END
