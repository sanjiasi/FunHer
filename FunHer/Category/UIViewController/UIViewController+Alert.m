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
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (actionHandler) {
            actionHandler();
        }
    }];
    
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 有取消和确定按钮
- (void)takeAlertWithTitle:(NSString *)title message:(NSString *)msg  actionBlock:(void (^)(void))actionBlock cancelBlock:(nonnull void (^)(void))cancelBlock {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        if (actionBlock) {
            actionBlock();
        }
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        if (cancelBlock) {
            cancelBlock();
        }
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)takeAlertWithTitle:(NSString *)title placeHolder:(NSString *)text actionBlock:(nonnull void (^)(NSString * _Nonnull))actionBlock cancelBlock:(nonnull void (^)(void))cancelBlock {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(alert) weakAlert = alert;
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        __strong typeof(weakAlert) strongAlert = weakAlert;
        if (!strongAlert.textFields.firstObject.text.length) {
            return;
        }
        NSString *text = strongAlert.textFields.firstObject.text;
        if (actionBlock) {
            actionBlock(text);
        }
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) {
            cancelBlock();
        }
    }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = @"folder name";
        textField.text = text;
    }];

    [alert addAction:okAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
    
    // 修改字体的颜色
//    [alertA setValue:[UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1] forKey:@"_titleTextColor"];
//    [alertB setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
}

@end
