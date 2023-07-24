//
//  DocRLM.h
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import <Realm/Realm.h>
#import "LZRLMObjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DocRLM : RLMObject<LZRLMObjectProtocol>
/**
 *  ID 主键
 */
@property NSString *Id;
/**
 *  文档名称
 */
@property NSString *name;
/**
 *  父id 上级目录的id
 */
@property NSString *parentId;
/**
 *  文件夹路径id  上级目录的pathId + Id
 */
@property NSString *pathId;
/**
 *  文件夹路径 **不存数据库 设置忽略属性
 */
@property (nonatomic) NSString *filePath;
/**
 *  创建时间 秒
 */
@property double cTime;
/**
 *  更新时间 秒
 */
@property double uTime;
/**
 *  查看时间 --reading 秒
 */
@property double rTime;
/**
 *  tags 01$02$  把标签文件名拼接加‘$’
 */
@property NSString *tags;
/**
 *  加载数据的耗时：毫秒
 */
@property int costTime;
/**
 *  文档密码
 */
@property NSString  *password;
/**
 *  同步数据是否完成
 */
@property BOOL syncDone;

@end

NS_ASSUME_NONNULL_END
