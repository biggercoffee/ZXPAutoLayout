//
//  ViewController.m
//  ZXPAutoLayoutDemo
//
/*
 
 version : 0.3.3
 support : Xcode7.0以上 , iOS 7 以上
 简洁方便的autolayout,有任何问题欢迎issue 我
 github : https://github.com/biggercoffee/ZXPAutolayout
 csdn blog : http://blog.csdn.net/biggercoffee
 QQ : 974792506
 
 */
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
    
    //uilabel 自适应 , 第一步设置numberOfLines = 0;第二步设置高度大于等于1(或者更大的数值)即可
    UILabel *label = [UILabel new];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"1.this is a test 2.this is a test 3.this is a test 4.this is a test";
    label.numberOfLines = 0; //----自适应第一步, numberoflines = 0
    [label zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.top.offset(200); //距离父视图的顶部距离为200
        layout.left.offset(20); //距离父视图的左侧距离为20
        layout.width.equalToWithMultiplier(self.view,0.5); //设置宽度为self.view的宽度的0.5(比例)
        layout.height.greaterThanOrEqual(@1); //-----自适应第二步,设置高度大于等于1即可
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
