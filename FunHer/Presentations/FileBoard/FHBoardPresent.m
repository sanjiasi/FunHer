//
//  FHBoardPresent.m
//  FunHer
//
//  Created by GLA on 2023/9/14.
//

#import "FHBoardPresent.h"
#import "FHFileModel.h"
#import "FHBoardCellModel.h"
#import "FHReadFileSession.h"

@implementation FHBoardPresent

- (NSArray *)getFileArray {
    if (self.folderType) {
        NSArray *folderArr = [FHReadFileSession entityListToDic:[FHReadFileSession foldersByParentId:self.fileObjId]];
        NSMutableArray *temp = @[].mutableCopy;
        [folderArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHBoardCellModel *model = [FHBoardCellModel createModelWithParam:obj];
            if (model) {
                [temp addObject:model];
            }
        }];
        self.dataArray = [NSArray arrayWithArray:temp];
    }
    return self.dataArray;
}

- (void)setSelectedIndex:(NSIndexPath *)selectedIndex {
    _selectedIndex = selectedIndex;
    FHBoardCellModel *model = self.dataArray[selectedIndex.row];
    self.selectedObjId = model.fileObj.objId;
}

- (NSString *)fileName {
    if ([self.fileObjId isEqualToString:FHParentIdByHome]) {
        return @"All";
    }
    NSDictionary *folder = [FHReadFileSession folderDicWithId:self.fileObjId];
    return folder[@"name"];
}

- (NSString *)filePath {
    if ([self.fileObjId isEqualToString:FHParentIdByHome]) {
        return @"All";
    }
    NSDictionary *folder = [FHReadFileSession folderDicWithId:self.fileObjId];
    NSString *pathId = folder[@"pathId"];
    NSArray *pathIds = [pathId componentsSeparatedByString:@"/"];
    NSString *fldPath = @"All";
    for (NSString *objId in pathIds) {
        if ([objId isEqualToString:FHParentIdByHome]) {//根目录
            continue;
        }
        NSDictionary *folder = [FHReadFileSession folderDicWithId:objId];
        fldPath = [fldPath stringByAppendingPathComponent:folder[@"name"]];
    }
    return fldPath;
}

@end
