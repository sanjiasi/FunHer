//
//  DocRLM.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "DocRLM.h"

@implementation DocRLM
//主键
+ (NSString *)primaryKey {
    return @"Id";
}

//设置属性默认值
+ (NSDictionary *)defaultPropertyValues{
    return @{@"syncDone":@0, @"tags":@""};
}

//设置忽略属性,即不存到realm数据库中
+ (NSArray<NSString *> *)ignoredProperties {
    return @[@"filePath", ];
}

//构造数据库模型--DocRLM
+ (instancetype)createRLMObjWithParam:(NSDictionary *)param {
    DocRLM *objRLM = [DocRLM yy_modelWithDictionary:param];
    if (!objRLM.Id) {
        objRLM.Id = [[NSUUID UUID] UUIDString];
    }
    return objRLM;
}

- (NSDictionary *)modelToDic {
    DocRLM *objRLM = (DocRLM *)self;
    return (NSDictionary *)[objRLM yy_modelToJSONObject];
}

@end
