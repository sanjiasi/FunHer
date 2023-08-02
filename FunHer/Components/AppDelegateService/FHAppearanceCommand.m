//
//  FHAppearanceCommand.m
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import "FHAppearanceCommand.h"

@implementation FHAppearanceCommand

- (void)execute {
    [self configureNavigationBar];
}

#pragma mark -- 全局配置导航栏
- (void)configureNavigationBar {
    //关闭透明
    [[UINavigationBar appearance] setTranslucent:NO];
    //去掉导航下边的黑线
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
}


@end
