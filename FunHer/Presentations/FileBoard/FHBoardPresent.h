//
//  FHBoardPresent.h
//  FunHer
//
//  Created by GLA on 2023/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHBoardPresent : NSObject

/// 移动/拷贝的对象
@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, assign) BOOL isCopy;//yes: 是拷贝
@property (nonatomic, assign) BOOL folderType;//yes：是文件夹
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, copy) NSString *selectedObjId;
@property (nonatomic, copy) NSString *fileObjId;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *filePath;

/// 获取目标文件，可复制或移动到这些文件
- (NSArray *)getFileArray;

@end

NS_ASSUME_NONNULL_END
