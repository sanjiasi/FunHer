//
//  FHCollectionMenu.m
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import "FHCollectionMenu.h"

@interface FHCollectionMenu ()
@property (nonatomic, copy) NSArray *dataSource;
@property (nonatomic, copy) ClickForAction actionBlock;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *actionBtn;

@end

@implementation FHCollectionMenu

- (instancetype)initWithItems:(NSArray *)itemArr actionBlock:(void (^)(NSInteger, NSString * _Nonnull))action {
    if (self = [super init]) {
        self.actionBlock = [action copy];
    }
    return self;
}



@end
