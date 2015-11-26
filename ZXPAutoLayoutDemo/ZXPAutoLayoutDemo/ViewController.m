//
//  ViewController.m
//  ZXPAutoLayoutDemo
//
//  Created by coffee on 15/11/14.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import "ViewController.h"
#import "ZXPAutoLayout.h"
#import <objc/runtime.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //------------- 简单使用示例的用法 --------------
    
    UIView *redView = [UIView new];
    [self.view addSubview:redView];
    redView.backgroundColor = [UIColor redColor];
    [redView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.edges.equalTo(self.view); //上 下 左 右 边距 距离self.view都为0,也就是和superview的坐标,宽高保持一致
    }];
    
    UIView *blueView = [UIView new];
    [redView addSubview:blueView];
    blueView.backgroundColor = [UIColor blueColor];
    [blueView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.top.left.offset(20); //上边距和左边距都距离superview 为20的距离
        layout.width.height.offset(100); //宽高等于100
    }];
    NSLog(@"blueView的约束:");
    [blueView zxp_printConstraintsForSelf]; //打印当前view的约束
    
    UIView *grayView = [UIView new];
    [self.view addSubview:grayView];
    grayView.backgroundColor = [UIColor grayColor];
    [grayView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.top.equalTo(blueView.zxp_bottom).offset(10);//在blueview的下边并加10的距离
        layout.left.offset(20); //距离superview左间距20
        layout.height.equalTo(blueView); //高度和blueview一样
        layout.width.equalTo(blueView).multiplier(0.5);//是blueview宽度的一半
    }];
    
    UIView *greenView = [UIView new];
    [self.view addSubview:greenView];
    greenView.backgroundColor = [UIColor greenColor];
    [greenView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.width.height.offset(100); //宽高等于100
        layout.center.equalTo(self.view); //在self.view里保持居中
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
