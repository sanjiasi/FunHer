//
//  FHBoardTableView.m
//  FunHer
//
//  Created by GLA on 2023/9/14.
//

#import "FHBoardTableView.h"
#import "FHBoardCell.h"
#import "FHBoardCellModel.h"

static const CGFloat FolderCellHeight = 90;

@interface FHBoardTableView ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation FHBoardTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.backgroundColor = kViewBGColor;
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        [self registerClass:[FHBoardCell class] forCellReuseIdentifier:NSStringFromClass([FHBoardCell class])];
    }
    return self;
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHBoardCellModel *model = self.dataArray[indexPath.row];
    FHBoardCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHBoardCell class]) forIndexPath:indexPath];
    [cell configCellWithData:model];
    return cell;
}
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FolderCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectFileBlock) {
        self.didSelectFileBlock(indexPath);
    }
}

@end
