//
//  FHEditItemsVC.m
//  FunHer
//
//  Created by GLA on 2023/9/8.
//

#import "FHEditItemsVC.h"
#import "FHEditItemPresent.h"
#import "FHFileModel.h"
#import "FHFileEditCellModel.h"
#import "FHFileEditCollectionCell.h"
#import "FHEditedCollectionView.h"
#import "FHCollectionMenu.h"

@interface FHEditItemsVC ()
@property (nonatomic, strong) UIView *superContentView;
@property (nonatomic, strong) FHEditedCollectionView *collectionView;
@property (nonatomic, strong) FHEditItemPresent *present;
@property (nonatomic, strong) FHCollectionMenu *funcMenu;
@property (nonatomic, strong) UIButton *navRightBtn;

@end

@implementation FHEditItemsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configNavBar];
    [self configContentView];
}

#pragma mark -- life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [LZDispatchManager globalQueueHandler:^{
        [self.present refreshData];
    } withMainCompleted:^{
        self.collectionView.dataArray = self.present.dataArray;
        [self.collectionView reloadData];
    }];
}

#pragma mark -- Delegate
- (void)collectionViewDidSelected:(NSIndexPath *)idxPath {
    FHFileEditCellModel *model = self.present.dataArray[idxPath.item];
    if ([model.fileObj.type isEqualToString:@"2"]) {//文档
        NSLog(@"selected == %@",model.fileName);
        [self refreshNavBarBySelected];
    }
}


#pragma mark -- event response
#pragma mark -- share
- (void)shareAction {
    NSLog(@"%s",__func__);
}

#pragma mark -- move/copy
- (void)copyAcion {
    NSLog(@"%s",__func__);
}

#pragma mark -- merge
- (void)mergeAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select a Merging Method" message:nil preferredStyle:IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"Merge And Keep Old Document" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self handleMergeAndKeepOldFile];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"Merge And Delete Old Document" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self handleMergeAndDeleteOldFile];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIColor * titleColor = UIColor.blackColor;
    [archiveAction setValue:titleColor forKey:@"_titleTextColor"];
    [otherAction setValue:titleColor forKey:@"_titleTextColor"];
    [alertController addAction:archiveAction];
    [alertController addAction:otherAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- 合并且保留原文件 等同于拷贝文件
- (void)handleMergeAndKeepOldFile {
    
}

#pragma mark -- 合并且删除原文件 等同往主文件移动文件
- (void)handleMergeAndDeleteOldFile {
    
}

#pragma mark -- delete
- (void)deleteAction {
    __weak typeof(self) weakSelf = self;
    [self takeAlertWithTitle:@"Warning" message:@"Are you sure you want to delete all selected documents ?" actionBlock:^{
        [weakSelf handleDeleteFile];
    } cancelBlock:^{
        NSLog(@"cancel");
    }];
}

- (void)handleDeleteFile {
    
}

#pragma mark -- 取消
- (void)clickCancelBtn {
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -- 全选/取消全选
- (void)clickSelectedAll {
    [self.present handSelectedAll];
    self.collectionView.dataArray = self.present.dataArray;
    [self.collectionView reloadData];
    [self refreshNavBarBySelected];
}

- (void)refreshNavBarBySelected {
    NSArray *results = [self.present selectedItemArray];
    if (self.present.selectedAll) {
        [self.navRightBtn setTitle:@"Deselect All" forState:UIControlStateNormal];
    } else {
        [self.navRightBtn setTitle:@"Select All" forState:UIControlStateNormal];
    }
    self.title = [NSString stringWithFormat:@"已选择%@项",@(results.count)];
}

#pragma mark -- public methods


#pragma mark -- private methods
#pragma mark -- 配置导航栏和子视图
- (void)configNavBar {
    self.title = self.selectedItem ? @"Selected 1" : @"Selected 0";
    [self setLeftButton:@"Cancel" withSelector:@selector(clickCancelBtn)];
    [self setRigthButton:@"Select All" withSelector:@selector(clickSelectedAll)];//Deselect All
}

- (void)configContentView {
    [self.view addSubview:self.superContentView];
    [self.superContentView addSubview:self.collectionView];
    [self.superContentView addSubview:self.funcMenu];
    
    [self.superContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(-kBottomSafeHeight);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.superContentView);
        make.top.equalTo(self.superContentView).offset(10);
        make.bottom.equalTo(self.superContentView).offset(-49);
    }];
    [self.funcMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.superContentView);
        make.top.equalTo(self.collectionView.mas_bottom).offset(0);
        make.bottom.equalTo(self.superContentView).offset(0);
    }];
}

- (void)setRigthButton:(nullable NSString *)title withSelector:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kThemeColor forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setFont:PingFang_R_FONT_(13)];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
    self.navRightBtn = btn;
}

- (void)setLeftButton:(nullable NSString *)title withSelector:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setFont:PingFang_R_FONT_(13)];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

#pragma mark -- getter and setters
- (FHEditItemPresent *)present {
    if (!_present) {
        _present = [[FHEditItemPresent alloc] init];
        _present.parentId = self.parentId;
        _present.selectedItem = self.selectedItem;
    }
    return _present;
}

- (UIView *)superContentView {
    if (!_superContentView) {
        UIView *content = [[UIView alloc] init];
        content.backgroundColor = kViewBGColor;
        _superContentView = content;
    }
    return _superContentView;
}

- (FHEditedCollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        CGFloat width = MIN(kScreenWidth, kScreenHeight);
        NSInteger columnCount = 3;
        CGFloat margin = 15;
        CGFloat padding = 10;
        CGFloat itemW = (width - padding*(columnCount-1) - margin*2)/columnCount;
        layout.itemSize = CGSizeMake(itemW, itemW * 1.4);
        layout.minimumInteritemSpacing = padding;
        layout.minimumLineSpacing = padding;
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
        
        FHEditedCollectionView *colView = [[FHEditedCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        colView.backgroundColor = kViewBGColor;//UIColor.whiteColor;
        __weak typeof(self) weakSelf = self;
        colView.didSelectedBlock = ^(NSIndexPath * _Nonnull aIndex) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf collectionViewDidSelected:aIndex];
        };
        
        _collectionView = colView;
    }
    return _collectionView;
}

- (FHCollectionMenu *)funcMenu {
    __weak typeof(self) weakSelf = self;
    if (!_funcMenu) {
        _funcMenu = [[FHCollectionMenu alloc] initWithItems:[self.present funcItems] menuHeight:49 actionBlock:^(NSInteger idx, NSString * _Nonnull selector) {
            NSLog(@"i = %@, func = %@", @(idx), selector);
            [weakSelf invokeWithSelector:selector];
        }];
        _funcMenu.bgColor = UIColor.whiteColor;
    }
    return _funcMenu;
}

@end
