//
//  UIViewController+Alert.m
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)

#pragma mark -- 只有确定按钮
- (void)takeAlert:(NSString *)title withMessage:(NSString *)message actionHandler:(void (^ _Nullable)(void))actionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"localized_ok" ,@"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (actionHandler) {
            actionHandler();
        }
    }];
    
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 有取消和确定按钮
- (void)takeAlertWithTitle:(NSString *)title message:(NSString *)msg  actionBlock:(void (^)(void))actionBlock cancleBlock:(void (^)(void))cancleBlock {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"localized_ok" ,@"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        if (actionBlock) {
            actionBlock();
        }
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"localized_cancel" ,@"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
