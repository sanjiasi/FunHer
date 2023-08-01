//
//  SSPopListView.m
//  SimpleScan
//
//  Created by GLA on 2022/6/30.
//  Copyright © 2022 admin3. All rights reserved.
//

#import "SSPopListView.h"
#import "ZLPhotoBrowserCell.h"
#import "ZLPhotoManager.h"
#import "ZLPhotoModel.h"

@interface SSPopListView ()<
UITableViewDelegate,
UITableViewDataSource
>
@property (strong, nonatomic) UIView *settingView;
@property (strong, nonatomic) UIView *maskLayer;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *closeBtn;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (copy, nonatomic) void(^selectBlock)(NSInteger index);

@end

@implementation SSPopListView

- (instancetype)initWithItems:(NSArray *)items selectedBlock:(void (^)(NSInteger))selectBlock {
    if (self = [super init]) {
        self.selectBlock = selectBlock;
        self.dataArray = [items mutableCopy];
        [self configContentView];
    }
    return self;
}

- (void)tapMaskViewHandle:(UITapGestureRecognizer *)sender {
    [self dismissActionView];
}

#pragma mark -- 展示
- (void)showActionView {
    [UIView animateWithDuration:0.2 animations:^{
        [self.settingView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kNavBarAndStatusBarHeight);
        }];
        //告知父类控件绘制，不添加注释的这两行的代码无法生效
        [self.settingView.superview layoutIfNeeded];
    }];
}

#pragma mark -- 隐藏
- (void)dismissActionView {
    [UIView animateWithDuration:0.2 animations:^{
        [self.settingView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(-(kNavBarAndStatusBarHeight + 460));
        }];
        [self.settingView.superview layoutIfNeeded];
        self.maskLayer.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissActionView];
}

#pragma mark -- 关闭
- (void)closeAlertView {
    [self dismissActionView];
}

- (void)addTapHandler {
    UIView *hitView = [[UIView alloc] init];
    hitView.backgroundColor = [UIColor viewControllerBackGroundColor:RGBA(0, 0, 0, 0.5) defaultColor:RGBA(0, 0, 0, 0.3)];
    [self addSubview:hitView];
    self.maskLayer = hitView;
    [self.maskLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kNavBarAndStatusBarHeight);
        make.leading.trailing.bottom.equalTo(self);
    }];
}

- (void)configContentView {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
//    self.backgroundColor = [UIColor viewControllerBackGroundColor:RGBA(0, 0, 0, 0.5) defaultColor:RGBA(0, 0, 0, 0.3)];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(keyWindow);
    }];
    
    [self addTapHandler];
    
    [self addSubview:self.settingView];
    [self.settingView addSubview:self.tableView];
    
    CGFloat settingViewH = 460;
    [self.settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(-(kNavBarAndStatusBarHeight + settingViewH));
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(settingViewH);
    }];
    [self.settingView.superview layoutIfNeeded];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.settingView);
    }];
    if (self.dataArray.count) {
        [self.tableView reloadData];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ZLPhotoManager getPhotoAblumList:NO allowSelectImage:YES complete:^(NSArray<ZLAlbumListModel *> *albums) {
                self.dataArray = [albums mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD resetOffsetFromCenter];
                    [self.tableView reloadData];
                });
            }];
        });
    }
}

#pragma mark -- tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLPhotoBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZLPhotoBrowserCell class])];
    
    if (!cell) {
        cell = [[kZLPhotoBrowserBundle loadNibNamed:NSStringFromClass([ZLPhotoBrowserCell class]) owner:self options:nil] lastObject];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    ZLAlbumListModel *albumModel = self.dataArray[indexPath.row];
    cell.cornerRadio = 2;
    cell.model = albumModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissActionView];
    if (self.selectBlock) {
        self.selectBlock(indexPath.row);
    }
}

#pragma mark -- lazy
- (UIView *)settingView {
    if (!_settingView) {
        _settingView = [[UIView alloc] init];
        _settingView.backgroundColor = [UIColor viewControllerBackGroundColor:KViewMainDarkColor defaultColor:[UIColor whiteColor]];
    }
    return _settingView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerNib:[UINib nibWithNibName:@"ZLPhotoBrowserCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([ZLPhotoBrowserCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

@end
