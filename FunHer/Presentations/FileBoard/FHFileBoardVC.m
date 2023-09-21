//
//  FHFileBoardVC.m
//  FunHer
//
//  Created by GLA on 2023/9/13.
//

#import "FHFileBoardVC.h"
#import "FHBoardPresent.h"
#import "FHBoardCellModel.h"
#import "FHBoardTableView.h"

@interface FHFileBoardVC ()
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic, strong) FHBoardTableView *tableView;
@property (nonatomic, strong) FHBoardPresent *present;
@property (nonatomic, strong) UILabel *titleLab;//标题
@property (nonatomic, strong) UILabel *contentLab;//内容
@property (nonatomic, strong) UIButton *cancelBtn;//取消
@property (nonatomic, strong) UIButton *actionBtn;//执行

@end

@implementation FHFileBoardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getEventWithName:NSStringFromClass([self class])];
    [self configContentView];
    [self configData];
}

- (void)clickCancelBtn {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    if (self.clickCancelBlock) {
        self.clickCancelBlock();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickActionBtn {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if (self.callBackFilePathBlock) {
        self.callBackFilePathBlock(self.present.selectedObjId);
    }
}

- (void)goToNextFolderVC {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    FHFileBoardVC *nextVC = [[FHFileBoardVC alloc] init];
    nextVC.fileObjId = self.present.selectedObjId;
    nextVC.fileHandleType = self.fileHandleType;
    nextVC.folderType = self.folderType;
    nextVC.selectedCount = self.selectedCount;
    nextVC.callBackFilePathBlock = self.callBackFilePathBlock;
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)configData {
    [LZDispatchManager globalQueueHandler:^{
        NSArray *data = [self.present getFileArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.dataArray = data;
            [self.tableView reloadData];
            self.title = self.present.fileName;
            self.titleLab.text = self.fileHandleType == FileHandleTypeCopy ? @"Copy to:" : @"Move to:";
            self.contentLab.text = self.present.filePath;
            NSString *btnTitle = self.fileHandleType == FileHandleTypeCopy ? [NSString stringWithFormat:@"Copy(%@)",@(self.selectedCount)] : [NSString stringWithFormat:@"Move(%@)",@(self.selectedCount)];
            [self.actionBtn setTitle:btnTitle forState:UIControlStateNormal];
        });
    }];
}

- (void)configContentView {
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.superContentView];
    [self.superContentView addSubview:self.titleLab];
    [self.superContentView addSubview:self.contentLab];
    [self.superContentView addSubview:self.tableView];
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = UIColor.whiteColor;
    [self.superContentView addSubview:bottomView];
    [bottomView addSubview:self.cancelBtn];
    [bottomView addSubview:self.actionBtn];
    
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(-kBottomSafeHeight);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.superContentView).offset(20);
        make.top.equalTo(self.superContentView);
        make.bottom.equalTo(self.tableView.mas_top).offset(0);
    }];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLab.mas_trailing).offset(5);
        make.centerY.equalTo(self.titleLab.mas_centerY).offset(0);
    }];
   
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.superContentView);
        make.top.equalTo(self.superContentView).offset(30);
    }];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.superContentView);
        make.top.equalTo(self.tableView.mas_bottom).offset(0);
        make.height.mas_equalTo(70);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.actionBtn.mas_leading).offset(-15);
        make.centerY.equalTo(self.actionBtn.mas_centerY).offset(0);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(bottomView).offset(-25);
        make.centerY.equalTo(bottomView);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.didSelectFileBlock = ^(NSIndexPath * _Nonnull aIndex) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.present.selectedIndex = aIndex;
        [strongSelf goToNextFolderVC];
    };
}

#pragma mark -- lazy
- (UIView *)superContentView {
    if (!_superContentView) {
        UIView *content = [[UIView alloc] init];
        content.backgroundColor = kViewBGColor;
        _superContentView = content;
    }
    return _superContentView;
}

- (FHBoardTableView *)tableView {
    if (!_tableView) {
        _tableView = [[FHBoardTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    return _tableView;
}

- (FHBoardPresent *)present {
    if (!_present) {
        _present = [[FHBoardPresent alloc] init];
        _present.isCopy = self.fileHandleType == FileHandleTypeCopy;
        _present.folderType = self.folderType;
        _present.fileObjId = self.fileObjId;
        _present.selectedObjId = self.fileObjId;
    }
    return _present;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = kTextGrayColor;
        lab.textAlignment = NSTextAlignmentNatural;
        lab.font = PingFang_R_FONT_(13);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLab = lab;
    }
    return _titleLab;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = kTextBlackColor;
        lab.textAlignment = NSTextAlignmentNatural;
        lab.font = PingFang_R_FONT_(13);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLab = lab;
    }
    return _contentLab;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"Cancel" forState:UIControlStateNormal];
        [btn setTitleColor:kThemeColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn = btn;
    }
    return _cancelBtn;
}

- (UIButton *)actionBtn {
    if (!_actionBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"Copy" forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [btn setBackgroundColor:kThemeColor];
        [btn addTarget:self action:@selector(clickActionBtn) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        btn.layer.masksToBounds = YES;
        _actionBtn = btn;
    }
    return _actionBtn;
}

- (void)dealloc {
    DELog(@"%s", __func__);
}

@end
