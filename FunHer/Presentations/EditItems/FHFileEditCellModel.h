//
//  FHFileEditCellModel.h
//  FunHer
//
//  Created by GLA on 2023/9/8.
//

#import <Foundation/Foundation.h>
#import "FHModelProtocol.h"

@class FHFileModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHFileEditCellModel : NSObject<FHModelProtocol>

@property (nonatomic, strong) FHFileModel *fileObj;
@property (nonatomic, copy) NSString *thumbNail;//缩率图
@property (nonatomic, copy) NSString *fileName;//名称
@property (nonatomic, copy) NSString *countNum;//统计数量
@property (nonatomic, copy) NSString *uDate;//文件更新时间
@property (nonatomic, assign) BOOL isSelected;


@end

NS_ASSUME_NONNULL_END

