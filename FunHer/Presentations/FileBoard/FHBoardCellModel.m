//
//  FHBoardCellModel.m
//  FunHer
//
//  Created by GLA on 2023/9/14.
//

#import "FHBoardCellModel.h"
#import "FHFileModel.h"
#import "FHReadFileSession.h"

@implementation FHBoardCellModel

- (NSString *)fileName {
    return self.fileObj.name;
}

+ (instancetype)createModelWithParam:(NSDictionary *)param {
    FHFileModel *fileObj = [FHFileModel createModelWithParam:param];
    FHBoardCellModel *model = [[FHBoardCellModel alloc] init];
    model.fileObj = fileObj;
    NSInteger imgCount = [fileObj.type isEqualToString:@"1"] ? [FHReadFileSession docCountAtFolder:fileObj.objId] : [FHReadFileSession imageCountAtDoc:fileObj.objId];
    imgCount = MIN(imgCount, 999);
    model.countNum = [NSString stringWithFormat:@"%@ ",@(imgCount)];
    return model;
}

- (NSDictionary *)modelToDic {
    FHBoardCellModel *model = (FHBoardCellModel *)self;
    NSDictionary *fileObj = [model.fileObj modelToDic];
    NSMutableDictionary *temp = [fileObj mutableCopy];
    temp[@"thumbNail"] = model.thumbNail;
    return [NSDictionary dictionaryWithDictionary:temp];
}

@end
