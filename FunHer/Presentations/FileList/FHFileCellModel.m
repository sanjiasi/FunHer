//
//  FHFileCellModel.m
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import "FHFileCellModel.h"
#import "FHFileModel.h"

@implementation FHFileCellModel

- (NSString *)fileName {
    return self.fileObj.name;
}

+ (instancetype)createModelWithParam:(NSDictionary *)param {
    FHFileModel *fileObj = [FHFileModel createModelWithParam:param];
    FHFileCellModel *model = [[FHFileCellModel alloc] init];
    model.fileObj = fileObj;
    return model;
}

- (NSDictionary *)modelToDic {
    FHFileCellModel *model = (FHFileCellModel *)self;
    NSDictionary *fileObj = [model.fileObj modelToDic];
    NSMutableDictionary *temp = [fileObj mutableCopy];
    temp[@"thumbNail"] = model.thumbNail;
    return [NSDictionary dictionaryWithDictionary:temp];
}

@end
