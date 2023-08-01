//
//  FHFileModel.h
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFileModel : NSObject
@property (nonatomic, copy) NSString *objId;//数据库对象主键
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *type; //1：文件夹 2：文档 3：图片
@property (nonatomic, copy) NSString *uTime;//修改时间
@property (nonatomic, copy) NSString *path;//文件路径
@property (nonatomic, assign) BOOL  selectStatus; //按钮状态 选中状态
@property (nonatomic, copy) NSString *gaussianBlurPath;//高斯模糊图片
@property (nonatomic, copy) NSString *coverImg;//缩略图
//@property (nonatomic, copy) NSString *movePath; // 移动的path 即文件夹的路径
//@property (nonatomic, copy) NSString *imagePath;//图片路径 doc文档时表示文档的第一张图的路径  image时表示图片的路径
//@property (nonatomic, copy) NSString *number; //foler：文档数量  document：图片数量 image：图片大小
//@property (nonatomic, assign) BOOL  isFile;  //(YES是文件, NO是文件夹)

@end

NS_ASSUME_NONNULL_END
