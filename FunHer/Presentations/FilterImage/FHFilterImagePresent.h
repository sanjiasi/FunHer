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
@property (nonatomic, copy) NSString *parentId;//上层目录文件id
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger selectdIndex;
@property (nonatomic, copy) NSString *cropImgPath;//裁剪后的图片

/// 刷新数据
- (void)refreshData;

- (void)didSelected:(NSInteger)indx;

@end

NS_ASSUME_NONNULL_END
