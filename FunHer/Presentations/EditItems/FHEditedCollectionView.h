//
//  FHEditedCollectionView.h
//  FunHer
//
//  Created by GLA on 2023/9/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidSelectedBlock)(NSIndexPath *aIndex);

@interface FHEditedCollectionView : UICollectionView

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) DidSelectedBlock didSelectedBlock;


@end

NS_ASSUME_NONNULL_END
