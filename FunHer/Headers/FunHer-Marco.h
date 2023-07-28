//
//  FunHer-Marco.h
//  FunHer
//
//  Created by GLA on 2023/7/21.
//

#ifndef FunHer_Marco_h
#define FunHer_Marco_h

#pragma mark -- functions
// 字符串判空
#define NULLString(string) ((![string isKindOfClass:[NSString class]]) || (string == nil) || [string isEqualToString:@""] || [string isEqualToString:@"<null>"] || [string isKindOfClass:[NSNull class]]||[[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)

#define KAppDelegate          ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define KAppWindow \
\
^(){ \
    UIWindow *window = [UIApplication sharedApplication].delegate.window; \
    if (!window) { \
        if (@available(iOS 13.0, *)) { \
            NSArray *array =[[[UIApplication sharedApplication] connectedScenes] allObjects]; \
            UIWindowScene *windowScene = (UIWindowScene*)array[0]; \
            UIWindow *mainWindow = [windowScene valueForKeyPath:@"delegate.window"]; \
            if(mainWindow) { \
                window = mainWindow; \
            } else { \
                window = [UIApplication sharedApplication].windows.lastObject; \
            } \
        } else { \
            window = [UIApplication sharedApplication].keyWindow; \
        } \
    } \
    return window; \
}()

// 判断是否为iPad
#define IS_IPAD   ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].length != 0)

// 判断是否为iPhoneX机型
#define IS_iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

// 设备的ios版本
#define DeviceSystemVersion ([UIDevice currentDevice].systemVersion.floatValue)

#define StringFormat(a) [NSString stringWithFormat:@"%@",a]

#pragma mark -- const
// -- 首页文件夹、文档的父id
#define FHParentIdByHome @"FF_00"
// -- 图片后缀
#define FHFilePathExtension @".jpg"

#pragma mark -- variable
// ----------  布局
// 屏幕宽、高
#define kScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

// 状态栏高度
#define kStatusBarHeight \
^(){\
if (@available(iOS 13.0, *)) {\
    UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;\
    return statusBarManager.statusBarFrame.size.height;\
} else {\
    return [UIApplication sharedApplication].statusBarFrame.size.height;\
}\
}()

// 底部安全区域高度
#define kBottomSafeHeight \
^(){\
if (@available(iOS 11.0, *)) {\
   UIEdgeInsets safeAreaInsets = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;\
   return safeAreaInsets.bottom;\
} else {\
   return UIEdgeInsetsMake(0, 0, 0, 0).bottom;\
}\
}()//34 , 0

// 导航栏高度
#define kNavBarHeight (IS_IPAD ? 50.0 : 44.0)

// 状态栏和导航栏总高度
#define kNavBarAndStatusBarHeight (kStatusBarHeight+kNavBarHeight)

// TabBar高度
#define kTabBarHeight (49.0 + kBottomSafeHeight)

// 导航条和Tabbar总高度
#define kNavAndTabHeight (kNavBarAndStatusBarHeight + kTabBarHeight)


#pragma mark -- 字体(size)规范
//basci
#define PingFang_L_FONT_(s)   [UIFont systemFontOfSize:s weight:UIFontWeightLight] //PingFangSC-Light//细
#define PingFang_R_FONT_(s)   [UIFont systemFontOfSize:s weight:UIFontWeightRegular]  //PingFangSC-Regular//常规
#define PingFang_M_FONT_(s)   [UIFont systemFontOfSize:s weight:UIFontWeightMedium] // //PingFangSC-Medium//中
#define PingFang_S_FONT_(s)   [UIFont systemFontOfSize:s weight:UIFontWeightSemibold]//PingFangSC-Semibold//粗

#pragma mark -- 颜色
#define RGB(r,g,b)          [UIColor colorWithRed:(r)/255.f \
                                            green:(g)/255.f \
                                             blue:(b)/255.f \
                                            alpha:1.f]

#define RGBA(r,g,b,a)       [UIColor colorWithRed:(r)/255.f \
                                            green:(g)/255.f \
                                             blue:(b)/255.f \
                                            alpha:(a)]

#endif /* FunHer_Marco_h */
