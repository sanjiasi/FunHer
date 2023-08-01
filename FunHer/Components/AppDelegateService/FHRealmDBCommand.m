//
//  FHRealmDBCommand.m
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import "FHRealmDBCommand.h"
#import "LZDBService.h"

@implementation FHRealmDBCommand

- (void)execute {
    [LZDBService configDBWithIdentifier:@"lz"];//构建数据库
    [LZDBService realmDBMigration];//数据库版本迁移 新增数据库表字段，记得更新数据库版本号
}

@end
