//
//  FHFilterImageVC.h
//  FunHer
//
//  Created by GLA on 2023/8/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFilterImageVC : UIViewController
@property (nonatomic, copy) NSString *objId;//图片Id
@property (nonatomic, copy) NSString *fileName;//原图
@property (nonatomic, copy) NSString *cropImgPath;//裁剪后的图片

@end

NS_ASSUME_NONNULL_END
