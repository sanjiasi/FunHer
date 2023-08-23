//
//  FHCropImageVC.h
//  FunHer
//
//  Created by GLA on 2023/8/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCropImageVC : UIViewController
@property (nonatomic, copy) NSString *objId;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *parentId;//上层目录文件id

@end

NS_ASSUME_NONNULL_END
