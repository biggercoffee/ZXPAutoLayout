//
//  ZXPStackViewController.m
//  ZXPAutoLayoutDemo
//
//  Created by coffee on 15/12/13.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import "ZXPStackViewController.h"
#import "ZXPAutoLayout.h"

@interface ZXPStackViewController ()

@end

@implementation ZXPStackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //传统的等宽, 水平对齐
    {/*
      UIView *view1 = [UIView new];
      [self.view addSubview:view1];
      view1.backgroundColor = [UIColor blueColor];
      
      UIView *view2 = [UIView new];
      [self.view addSubview:view2];
      view2.backgroundColor = [UIColor blackColor];
      
      UIView *view3 = [UIView new];
      [self.view addSubview:view3];
      view3.backgroundColor = [UIColor blueColor];
      
      [view1 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
      layout.topSpaceByView(grayView,10);
      layout.leftSpace(20);
      layout.heightValue(40);
      layout.widthEqualTo(view2);
      }];
      
      [view2 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
      layout.topSpaceEqualTo(view1,0);
      layout.leftSpaceByView(view1,20);
      layout.heightValue(40);
      layout.widthEqualTo(view3);
      }];
      
      [view3 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
      layout.topSpaceEqualTo(view1,0);
      layout.leftSpaceByView(view2,20);
      layout.rightSpace(20);
      layout.heightValue(40);
      }];
      */
    }
    
    //等宽, 水平对齐
    // ZXPStackView 的使用
    {
        ZXPStackView *stackView = [ZXPStackView new];
        [self.view addSubview:stackView];
        stackView.backgroundColor = [UIColor blackColor];
        
        //只需要设置stackView的宽高和位置即可
        [stackView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.topSpace(100);
            layout.leftSpace(0);
            layout.rightSpace(0);
            layout.heightValue(100);
        }];
        
        UIView *view1 = [UIView new];
        [stackView addSubview:view1];
        view1.backgroundColor = [UIColor blueColor];
        
        UIView *view2 = [UIView new];
        [stackView addSubview:view2];
        view2.backgroundColor = [UIColor yellowColor];
        
        UIView *view3 = [UIView new];
        [stackView addSubview:view3];
        view3.backgroundColor = [UIColor redColor];
        
        //stack的内边距
        stackView.padding = UIEdgeInsetsMake(10, 10, 10,10);
        //view直接的距离
        stackView.space = 10;
        
        /*
            调用此方法会给subviews自动添加约束条件,进行等宽或者等高排列
            type如果指定为 ZXPStackViewTypeVertical 就是垂直等高对齐了
         */
        [stackView layoutWithType:ZXPStackViewTypeHorizontal];
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    [btn setTitle:@"dismiss" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.topSpace(20);
        layout.rightSpace(20);
        layout.widthValue(100);
        layout.heightValue(40);
    }];
    
}

- (void)buttonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
