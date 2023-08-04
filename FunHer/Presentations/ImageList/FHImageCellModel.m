//
//  FHImageCellModel.m
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import "FHImageCellModel.h"
#import "FHFileModel.h"
#import "FHReadFileSession.h"

@implementation FHImageCellModel

+ (instancetype)createModelWithParam:(NSDictionary *)param {
    FHFileModel *fileObj = [FHFileModel createModelWithParam:param];
    FHImageCellModel *model = [[FHImageCellModel alloc] init];
    model.fileObj = fileObj;
    return model;
}

- (NSDictionary *)modelToDic {
    FHImageCellModel *model = (FHImageCellModel *)self;
    NSDictionary *fileObj = [model.fileObj modelToDic];
    NSMutableDictionary *temp = [fileObj mutableCopy];
    temp[@"thumbNail"] = model.thumbNail;
    return [NSDictionary dictionaryWithDictionary:temp];
}

@end
