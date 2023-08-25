//
//  FHFilterCellModel.h
//  FunHer
//
//  Created by GLA on 2023/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFilterCellModel : NSObject

@property (nonatomic ,copy) NSString *image;
@property (nonatomic ,copy) NSString *title;
@property (nonatomic ,assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
