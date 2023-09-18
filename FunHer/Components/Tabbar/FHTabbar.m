//
//  FHTabbar.m
//  FunHer
//
//  Created by GLA on 2023/9/15.
//

#import "FHTabbar.h"
#import "FHTabBarItem.h"
#import "FHTabMenuAdapter.h"

@interface FHTabbar ()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FHTabMenuAdapter *collectionAdapter;
@property (nonatomic, copy) NSArray *dataSource;
@property (nonatomic, copy) ClickForAction actionBlock;
@property (nonatomic, assign) CGFloat menuHeight;

@end

@implementation FHTabbar

#pragma mark -- life cycle
- (instancetype)initWithItems:(NSArray *)itemArr menuHeight:(CGFloat)height actionBlock:(nonnull ClickForAction)action {
    if (self = [super init]) {
        _menuHeight = height;
        _actionBlock = [action copy];
        _dataSource = itemArr;
        [self configContentView];
        [self configData];
    }
    return self;
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    self.backgroundColor = bgColor;
}

- (void)configContentView {
    self.backgroundColor = RGB(241, 241, 241);
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    
    self.collectionView.dataSource = self.collectionAdapter;
    self.collectionView.delegate = self.collectionAdapter;
}

- (void)configData {
    [self.collectionAdapter addDataArray:self.dataSource];
    [self.collectionView reloadData];
}

- (void)reloadWithItems:(NSArray *)itemArr {
    _dataSource = itemArr;
    [self configData];
}

#pragma mark -- Delegate
- (void)collectionViewDidSelected:(NSIndexPath *)idx withModel:(NSDictionary *)model {
    BOOL enable = [model[@"enable"] boolValue];
    if (!enable) return;
    if (model[@"selector"]) {
        if (self.actionBlock) {
            self.actionBlock(idx.item, model[@"selector"]);
        }
    }
}


#pragma mark -- getter and setters
- (FHTabMenuAdapter *)collectionAdapter {
    __weak typeof(self) weakSelf = self;
    if (!_collectionAdapter) {
        FHTabMenuAdapter *adapter = [[FHTabMenuAdapter alloc] initWithIdentifier:NSStringFromClass([FHTabBarItem class]) configureBlock:^(FHTabBarItem *cell, NSDictionary *model, NSIndexPath * _Nonnull indexPath) {
            cell.showImg.image = [UIImage imageNamed:model[@"image"]];
            cell.titleLab.text = model[@"title"];
            cell.enable = [model[@"enable"] boolValue];
        } didSelectedBlock:^(NSDictionary *model, NSIndexPath * _Nonnull indexPath) {
            [weakSelf collectionViewDidSelected:indexPath withModel:model];
        }];
        _collectionAdapter = adapter;
    }
    return _collectionAdapter;
}


- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        CGFloat width = MIN(kScreenWidth, kScreenHeight);
        NSInteger columnCount = self.dataSource.count;
        CGFloat margin = 15;
        CGFloat padding = 10;
        CGFloat itemW = (width - padding*(columnCount-1) - margin*2)/columnCount;
        layout.itemSize = CGSizeMake(itemW, self.menuHeight);
        layout.minimumInteritemSpacing = padding;
        layout.minimumLineSpacing = padding;
        layout.sectionInset = UIEdgeInsetsMake(0, margin, 0, margin);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[FHTabBarItem class] forCellWithReuseIdentifier:NSStringFromClass([FHTabBarItem class])];
    }
    return _collectionView;
}

@end
