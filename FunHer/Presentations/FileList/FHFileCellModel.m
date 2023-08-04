//
//  FHFileCellModel.m
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import "FHFileCellModel.h"
#import "FHFileModel.h"
#import "FHReadFileSession.h"

@implementation FHFileCellModel

- (NSString *)fileName {
    return self.fileObj.name;
}

+ (instancetype)createModelWithParam:(NSDictionary *)param {
    FHFileModel *fileObj = [FHFileModel createModelWithParam:param];
    FHFileCellModel *model = [[FHFileCellModel alloc] init];
    model.fileObj = fileObj;
    model.uDate = [NSDate timeDefaultFormatterWithDate:[fileObj.uTime doubleValue]];
    NSInteger imgCount = [fileObj.type isEqualToString:@"1"] ? [FHReadFileSession docCountAtFolder:fileObj.objId] : [FHReadFileSession imageCountAtDoc:fileObj.objId];
    imgCount = MIN(imgCount, 999);
    model.countNum = [NSString stringWithFormat:@"%@ ",@(imgCount)];
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
