//
//  FHAppearanceCommand.m
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#import "FHAppearanceCommand.h"

@implementation FHAppearanceCommand

- (void)execute {
    [self getEventWithName:NSStringFromSelector(_cmd)];
    [self configureNavigationBar];
}

#pragma mark -- 全局配置导航栏
- (void)configureNavigationBar {
    //关闭透明
    [[UINavigationBar appearance] setTranslucent:NO];
    //去掉导航下边的黑线
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTintColor:kTextBlackColor];
    NSDictionary *textAtt = @{NSForegroundColorAttributeName:kTextBlackColor};
    if (@available(iOS 13.0, *)){
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = kWhiteColor;
        appearance.titleTextAttributes = textAtt;
        appearance.shadowColor = [UIColor clearColor];
        [appearance setBackIndicatorImage:[UIImage imageNamed:@"backItem"] transitionMaskImage:[UIImage imageNamed:@"backItem"]];
        [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];
        [[UINavigationBar appearance] setStandardAppearance:appearance];
    } else {
        [[UINavigationBar appearance] setTitleTextAttributes:textAtt];
    }
}


@end
