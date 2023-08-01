//
//  FHFileListPresent.m
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import "FHFileListPresent.h"
#import "FHFileCellModel.h"

@implementation FHFileListPresent

- (instancetype)init {
    if (self = [super init]) {
        [self loadData];
    }
    return self;
}

#pragma mark -- Delegate
- (void)selectItemCount:(NSString *)num indexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -- private methods
- (void)loadData {
    FHFileCellModel *model1 = [[FHFileCellModel alloc] init];
}

#pragma mark -- getter and setters
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

@end
