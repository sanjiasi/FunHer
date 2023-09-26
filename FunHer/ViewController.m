//
//  ViewController.m
//  FunHer
//
//  Created by GLA on 2023/7/18.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"FunHer";
    self.view.backgroundColor = UIColor.systemPinkColor;
    
    UIView *tempView = [[UIView alloc] init];
    tempView.backgroundColor = UIColor.yellowColor;
    [self.view addSubview:tempView];
    
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    NSString *path = @"ff_00";
    NSLog(@"--1 = %@", [path lastPathComponent]);
    NSString *path2 = @"ff_00/1234/456"; 
    NSLog(@"--2 = %@", [path2 lastPathComponent]);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
