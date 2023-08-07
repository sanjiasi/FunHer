//
//  FHTabMenuAdapter.h
//  FunHer
//
//  Created by GLA on 2023/8/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^CellConfigureBefore)(id cell, id model, NSIndexPath *indexPath);
typedef void (^DidSelectedCell)(id model, NSIndexPath *indexPath);

@interface FHTabMenuAdapter : NSObject<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;//数据源
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) CellConfigureBefore cellConfigureBefore;
@property (nonatomic, copy) DidSelectedCell selectedBlock;//点击cell回调

/// 自定义
- (id)initWithIdentifier:(NSString *)identifier configureBlock:(CellConfigureBefore)before didSelectedBlock:(DidSelectedCell)selected;

/// 设置数据源
- (void)addDataArray:(NSArray *)datas;

/// 获取model
- (id)modelsAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
