//
//  FolderRLM.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "FolderRLM.h"

@implementation FolderRLM
//主键
+ (NSString *)primaryKey {
    return @"Id";
}

//设置属性默认值
+ (NSDictionary *)defaultPropertyValues{
    return @{@"syncDone":@0,};
}

//设置忽略属性,即不存到realm数据库中
+ (NSArray<NSString *> *)ignoredProperties {
    return @[ ];
}

//构造数据库模型--FolderRLM
+ (instancetype)createRLMObjWithParam:(NSDictionary *)param {
    FolderRLM *objRLM = [FolderRLM yy_modelWithDictionary:param];
    if (!objRLM.Id) {
        objRLM.Id = [[NSUUID UUID] UUIDString];
    }
    return objRLM;
}

- (NSDictionary *)modelToDic {
    FolderRLM *objRLM = (FolderRLM *)self;
    return (NSDictionary *)[objRLM yy_modelToJSONObject];
}

@end
