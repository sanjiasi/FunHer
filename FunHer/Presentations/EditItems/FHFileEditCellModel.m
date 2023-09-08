//
//  FHFileEditCellModel.m
//  FunHer
//
//  Created by GLA on 2023/9/8.
//

#import "FHFileEditCellModel.h"
#import "FHFileModel.h"
#import "FHReadFileSession.h"

@implementation FHFileEditCellModel

- (NSString *)fileName {
    return self.fileObj.name;
}

+ (instancetype)createModelWithParam:(NSDictionary *)param {
    FHFileModel *fileObj = [FHFileModel createModelWithParam:param];
    FHFileEditCellModel *model = [[FHFileEditCellModel alloc] init];
    model.fileObj = fileObj;
    model.uDate = [NSDate timeDefaultFormatterWithDate:[fileObj.uTime doubleValue]];
    NSInteger imgCount = [fileObj.type isEqualToString:@"1"] ? [FHReadFileSession docCountAtFolder:fileObj.objId] : [FHReadFileSession imageCountAtDoc:fileObj.objId];
    imgCount = MIN(imgCount, 999);
    model.countNum = [NSString stringWithFormat:@"%@ ",@(imgCount)];
    return model;
}

- (NSDictionary *)modelToDic {
    FHFileEditCellModel *model = (FHFileEditCellModel *)self;
    NSDictionary *fileObj = [model.fileObj modelToDic];
    NSMutableDictionary *temp = [fileObj mutableCopy];
    temp[@"thumbNail"] = model.thumbNail;
    return [NSDictionary dictionaryWithDictionary:temp];
}

@end
