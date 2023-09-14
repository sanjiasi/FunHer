//
//  FHFileModel.h
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import <Foundation/Foundation.h>
#import "FHModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFileModel : NSObject<FHModelProtocol>
@property (nonatomic, copy) NSString *objId;//数据库对象主键
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type; //1：文件夹 2：文档 3：图片
@property (nonatomic, copy) NSString *uTime;//修改时间
@property (nonatomic, copy) NSString *cTime;//创建时间

@end

NS_ASSUME_NONNULL_END
