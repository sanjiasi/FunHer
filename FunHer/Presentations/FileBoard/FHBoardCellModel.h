//
//  FHBoardCellModel.h
//  FunHer
//
//  Created by GLA on 2023/9/14.
//

#import <Foundation/Foundation.h>
#import "FHModelProtocol.h"

@class FHFileModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHBoardCellModel : NSObject<FHModelProtocol>
@property (nonatomic, strong) FHFileModel *fileObj;
@property (nonatomic, copy) NSString *thumbNail;//缩率图
@property (nonatomic, copy) NSString *fileName;//名称
@property (nonatomic, copy) NSString *countNum;//统计数量

@end

NS_ASSUME_NONNULL_END


