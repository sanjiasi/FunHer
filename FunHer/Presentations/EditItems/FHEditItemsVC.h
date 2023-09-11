//
//  FHEditItemsVC.h
//  FunHer
//
//  Created by GLA on 2023/9/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHEditItemsVC : UIViewController

@property (nonatomic, copy) NSString *parentId;//父目录对象Id
@property (nonatomic, copy) NSString *selectedItem;//已经选中的对象Id
@property (nonatomic, strong) NSIndexPath *selectedIndex;

/// 复制/移动到新的目录
@property (nonatomic, copy) void(^moveCopyToPathBlock)(NSString *objectId);
/// 合并文件
@property (nonatomic, copy) void(^mergeToNewFileBlock)(NSString *objectId);
/// 删除文件
@property (nonatomic, copy) void(^deleteFileBlock)(void);
/// 分享文件
@property (nonatomic, copy) void(^shareFileBlock)(void);

@end

NS_ASSUME_NONNULL_END
