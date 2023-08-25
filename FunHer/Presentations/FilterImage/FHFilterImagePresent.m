//
//  FHFilterImagePresent.m
//  FunHer
//
//  Created by GLA on 2023/8/24.
//

#import "FHFilterImagePresent.h"
#import "FHFilterCellModel.h"

@interface FHFilterImagePresent ()
@property (nonatomic ,strong) CIContext * context;//Core Image上下文
@property (nonatomic ,strong) CIFilter * colorControlsFilter;//色彩滤镜

@end

@implementation FHFilterImagePresent

- (void)refreshData {
    NSArray *arr = @[@"original.jpg", @"color.jpg", @"shadow.jpg", @"whiteblack.jpg", @"blackwhite.jpg", @"gray.jpg"];
    NSMutableArray *dataSource = @[].mutableCopy;
    [arr enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *imgData = [NSData dataWithContentsOfFile:self.cropImgPath];
        NSString *filePath = [NSString tempCropImagePath:name];
        [UIImage shrinkImage:imgData imageSize:CGSizeMake(80, 90) saveAtPath:filePath];
        FHFilterCellModel *model = [[FHFilterCellModel alloc] init];
        model.image = filePath;
        model.title = [name fileNameNOSuffix];
        model.isSelect = idx == self.selectdIndex ? YES : NO;
        [dataSource addObject:model];
    }];
    self.dataArray = [dataSource mutableCopy];
}

- (void)didSelected:(NSInteger)indx {
    if (self.selectdIndex == indx) return;
    self.selectdIndex = indx;
    [self.dataArray enumerateObjectsUsingBlock:^(FHFilterCellModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelect = indx == idx ? YES : NO;
    }];
}

#pragma mark -- lazy
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

@end
