//
//  FHFileModel.m
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import "FHFileModel.h"

@implementation FHFileModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return@{@"objId" :@[@"Id",@"objId",],
             @"type" :@[@"type",],
             @"name" :@[@"name",],
    };
}

+ (instancetype)createModelWithParam:(NSDictionary *)param {
    FHFileModel *model = [FHFileModel yy_modelWithDictionary:param];
    return model;
}

//模型转字典
- (NSDictionary *)modelToDic {
    FHFileModel *obj = (FHFileModel *)self;
    return (NSDictionary *)[obj yy_modelToJSONObject];
}


@end
