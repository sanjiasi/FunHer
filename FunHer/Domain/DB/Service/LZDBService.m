//
//  LZDBService.m
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import "LZDBService.h"
#import <Realm/Realm.h>

static NSString * const DBFilePrefix = @"FunHer_db_";
//realm 数据库版本迁移,每次改变数据库结构时,请将 REALM_SCHAME_VERSION 值加 1,并保证REALM_SCHAME_VERSION为正整数
static NSUInteger  const REALM_SCHAME_VERSION = 1;

@implementation LZDBService

/// 配置数据库
/// @param identifier  数据库标识符（建议用唯一标识）
+ (void)configDBWithIdentifier:(NSString *)identifier {
    if ([identifier length]) {
        NSString *dbName = [NSString stringWithFormat:@"%@%@.realm",DBFilePrefix,identifier];//数据库名
        NSString *dbPath = DBFilePrefix;//[CNSandbox getDBPathString];//数据库目录//getMessagePhotoPathString
        NSString *dbFile = [dbPath stringByAppendingPathComponent:dbName];//数据库文件路径

        RLMRealmConfiguration *defaultConfig = [RLMRealmConfiguration defaultConfiguration];
        defaultConfig.fileURL = [NSURL fileURLWithPath:dbFile];
        defaultConfig.schemaVersion = 1;
        [RLMRealmConfiguration setDefaultConfiguration:defaultConfig];
//        NSLog(@"DBPath:%@",defaultConfig.fileURL);
    }
}


/// 数据库版本迁移
/*
 更详细具体请参考realm官方技术文档，关于 Objective‑C 数据迁移
 https://realm.io/cn/docs/objc/latest/#migrations
 */
#warning 改变数据库模型类，如新增字段或者删除字段，如果需要做对应的处理，就在对应的版本，处理对应的字段，如果不需要处理这些字段，可以什么也不写，只需要增加‘REALM_SCHAME_VERSION’的版本号，每次变更都需要加 1
+ (void)realmDBMigration {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = REALM_SCHAME_VERSION;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
//        if (oldSchemaVersion < 9) {
//            [migration enumerateObjects:AppDocument.className
//                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
//                newObject[@"docNoticeLock"] = @(0);
//            }];
//        }
//        if (oldSchemaVersion < 12) {
//            [migration enumerateObjects:AppDocument.className
//                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
//                newObject[@"rtime"] = oldObject[@"utime"];
//            }];
//        }
//        if (oldSchemaVersion < 21) {
//            [migration enumerateObjects:SendFaxInfo.className block:^(RLMObject * _Nullable oldObject, RLMObject * _Nullable newObject) {
//                NSDate *uDate= oldObject[@"utime"];
//                newObject[@"utimeDate"] = uDate;
//                newObject[@"utime"] = @([uDate timeIntervalSince1970]);
//            }];
//        }
//        if (oldSchemaVersion < 22) {
//            [migration enumerateObjects:SendFaxInfo.className block:^(RLMObject * _Nullable oldObject, RLMObject * _Nullable newObject) {
//                newObject[@"coverIndex"] = @(0);
//            }];
//        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

/// 返回当前使用的数据库实例
+ (RLMRealm *)currentRealm {
    RLMRealm *realm = [RLMRealm defaultRealm];
    return realm;
}

/// 执行事务
/// @param block 事务执行内容
+ (void)transactionWithBlock:(void(^)(void))block {
    RLMRealm *realm = [self currentRealm];
    [realm transactionWithBlock:block];
}

/// 清空数据库
+ (void)clearRealmDB {
    RLMRealm *realm = [self currentRealm];
    // 每个线程只需要使用一次即可
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
    }];
}

/// 删除单个
/// @param object 删除对象
+ (void)removeObject:(id)object {
    if (object) {
        if ([object isKindOfClass:[RLMObject class]]) {
            RLMObject *model = (RLMObject *)object;
            if (model.isInvalidated) {
                return;
            }
            RLMRealm *realm = [self currentRealm];
            // 每个线程只需要使用一次即可
            [realm transactionWithBlock:^{
                [realm deleteObject:object];
            }];
        }
    }
}

/// 删除多个
/// @param objects 删除对象
+ (void)removeAllObjects:(id)objects {
    if (objects) {
        RLMRealm *realm = [self currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm deleteObjects:objects];
        }];
    }
}

/// 保存单个
/// @param object 保存对象
+ (void)saveObject:(id)object {
    if (object) {
        RLMRealm *realm = [self currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm addObject:object];
        }];
    }
}

/// 保存更新单个 不是增量更新，所有的字段必须有值，如果有几个字段值是null，会覆盖原来的值
/// @param object 保存对象
+ (void)addOrUpdateObject:(id)object {
    if (object) {
        RLMRealm *realm = [self currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm addOrUpdateObject:object];
        }];
    }
}

/// 保存更新多个
/// @param objects 保存对象
+ (void)addOrUpdateObjects:(id)objects {
    if (objects) {
        RLMRealm *realm = [self currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm addOrUpdateObjects:objects];
        }];
    }
}

/// 保存多个
/// @param objects 保存对象
+ (void)saveAllObjects:(id)objects {
    if (objects) {
        RLMRealm *realm = [self currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm addObjects:objects];
        }];
    }
}

/// 删除、保存多个对象
/// @param objects 删除对象组
/// @param addObjs 保存对象组
+ (void)deleteObjects:(id)objects saveObjects:(id)addObjs {
    NSMutableArray *delArr = @[].mutableCopy;
    if ([objects isKindOfClass:[NSArray class]]) {
        for (RLMObject *obj in objects) {
            if (!obj.isInvalidated) {
                [delArr addObject:obj];
            }
        }
        objects = delArr;
    } else {
        objects = @[].mutableCopy;
    }
    if (objects && addObjs) {
        RLMRealm *realm = [self currentRealm];
        // 每个线程只需要使用一次即可
        [realm transactionWithBlock:^{
            [realm deleteObjects:objects];
            [realm addObjects:addObjs];
        }];
    }
}

+ (void)batchUpdateObjects:(id)objects data:(NSDictionary *)data {
    if (objects && data) {
        RLMRealm *realm = [self currentRealm];
        [realm transactionWithBlock:^{
            // 将每个 object 对象的 keyPath 属性设置为 value
            for (NSString *keyPath in data) {
                [objects setValue:data[keyPath] forKeyPath:keyPath];
            }
        }];
    }
}

+ (NSArray *)convertToArray:(id)results {
    NSMutableArray *array = [NSMutableArray array];
    for (RLMObject *object in results) {
        [array addObject:object];
    }
    return [NSArray arrayWithArray:array];
}


@end
