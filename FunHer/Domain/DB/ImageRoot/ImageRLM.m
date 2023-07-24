//
//  ImageRLM.m
//  FunHer
//
//  Created by GLA on 2023/7/24.
//

#import "ImageRLM.h"

@implementation ImageRLM

//主键
+ (NSString *)primaryKey {
    return @"Id";
}

//设置属性默认值
+ (NSDictionary *)defaultPropertyValues{
    return @{@"syncDone":@0, };
}

//设置忽略属性,即不存到realm数据库中
+ (NSArray<NSString *> *)ignoredProperties {
    return @[@"filePath", @"fileName"];
}

//构造数据库模型--ImageRLM
+ (instancetype)createRLMObjWithParam:(NSDictionary *)param {
    ImageRLM *objRLM = [ImageRLM yy_modelWithDictionary:param];
    if (!objRLM.Id) {
        objRLM.Id = [[NSUUID UUID] UUIDString];
    }
    return objRLM;
}

- (NSDictionary *)modelToDic {
    ImageRLM *objRLM = (ImageRLM *)self;
    return (NSDictionary *)[objRLM yy_modelToJSONObject];
}

@end
