//
//  FHFileBoardVC.h
//  FunHer
//
//  Created by GLA on 2023/9/13.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FileHandleType) {
    FileHandleTypeCopy, //拷贝
    FileHandleTypeMove, //移动
};

NS_ASSUME_NONNULL_BEGIN

@interface FHFileBoardVC : UIViewController

/// 移动/拷贝的对象
@property (nonatomic, assign) NSInteger selectedCount;

@property (nonatomic, copy) NSString *fileObjId;

/**
 文件操作类型 ：拷贝、 移动
 */
@property (nonatomic, assign) FileHandleType fileHandleType;

/// 文件夹
@property (nonatomic, assign) BOOL folderType;

/// 选择复制/移动到的目录
@property (nonatomic, copy) void(^callBackFilePathBlock)(NSString *objectId);

/// 取消并返回到上个界面
@property (nonatomic, copy) void(^clickCancelBlock)(void);

@end

NS_ASSUME_NONNULL_END
