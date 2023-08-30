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
    NSDictionary *textAtt = @{NSForegroundColorAttributeName:RGBA(51, 51, 51, 1.0)};
    if (@available(iOS 15.0, *)){
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        appearance.titleTextAttributes = textAtt;
        appearance.shadowColor = [UIColor clearColor];
        [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];
        [[UINavigationBar appearance] setStandardAppearance:appearance];
    } else {
        [[UINavigationBar appearance] setTitleTextAttributes:textAtt];
    }
}


@end
