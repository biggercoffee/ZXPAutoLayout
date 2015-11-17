//
//  ViewController.m
//  ZXPAutoLayoutDemo
//
//  Created by coffee on 15/11/14.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import "ViewController.h"
#import "ZXPAutoLayout.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIView *view = [UIView new];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor redColor];
    [view zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.edges.equalTo(self.view); //上下左右边距等于self.view
    }];
    [view zxp_printConstraintsForSelf];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
