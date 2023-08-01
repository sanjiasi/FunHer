//
//  FHFileListPresent.h
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import <Foundation/Foundation.h>

@protocol ListPresentDelegate <NSObject>

@optional

- (void)selectItemCount:(NSString *)num indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_BEGIN

@interface FHFileListPresent : NSObject<ListPresentDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, weak) id<ListPresentDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
