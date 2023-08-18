//
//  FHImageCellModel.h
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import <Foundation/Foundation.h>
#import "FHModelProtocol.h"

@class FHFileModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHImageCellModel : NSObject<FHModelProtocol>

@property (nonatomic, strong) FHFileModel *fileObj;
@property (nonatomic, copy) NSString *thumbNail;//缩率图
@property (nonatomic, copy) NSString *fileName;//名称
@property (nonatomic, copy) NSString *fileSize;//文件大小
@property (nonatomic, copy) NSString *filePath;//文件路径

@end

NS_ASSUME_NONNULL_END
