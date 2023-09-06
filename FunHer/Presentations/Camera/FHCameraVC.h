//
//  FHCameraVC.h
//  FunHer
//
//  Created by GLA on 2023/9/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCameraVC : UIViewController
@property (nonatomic, copy) void(^getPhotoBlock)(NSData *photoImage);

@end

NS_ASSUME_NONNULL_END
