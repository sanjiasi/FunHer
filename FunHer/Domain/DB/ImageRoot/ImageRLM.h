//
//  ImageRLM.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Realm/Realm.h>
#import "LZRLMObjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageRLM : RLMObject<LZRLMObjectProtocol>
/**
 *  ID
 */
@property NSString *Id;
/**
 *  父id  上级目录的id
 */
@property NSString *parentId;
/**
 *  文件夹路径id 上级目录的pathId + Id
 */
@property NSString *pathId;
/**
 *  文件名字 自动生成
 */
@property NSString *name;
/**
 *  文件大小 Bit
 */
@property long fileLength;
/**
 *  图片名 01，02，03 **不存数据库 设置忽略属性
 */
@property NSString *fileName;
/**
 *  创建时间
 */
@property double cTime;
/**
 *  更新时间
 */
@property double uTime;
/**
 *  文件在云端的下载链接
 */
@property NSString *cloudUrl;
/**
 *  同步数据是否完成
 */
@property BOOL syncDone;

@end

NS_ASSUME_NONNULL_END
