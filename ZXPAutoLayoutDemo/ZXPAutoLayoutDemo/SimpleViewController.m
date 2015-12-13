//
//  SimpleViewController.m
//  ZXPAutoLayoutDemo
//
//  Created by coffee on 15/12/13.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import "SimpleViewController.h"
#import "ZXPAutoLayout.h"

@interface SimpleViewController ()

@end

@implementation SimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //------------- 简单使用示例的用法 --------------
    
    
    /*
     一些基本操作示例
     */
    
    //设置一个背景为半透明红色的view,上下左右四边都距离superview的距离为10
    UIView *bgView = [UIView new];
    [self.view addSubview:bgView];
    bgView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.5];
    [bgView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        //上下左右四边都距离superview的距离为10
        layout.edgeInsets(UIEdgeInsetsMake(10, 10, 10, 10));
        
        //也可以如下这行代码来设置,但要同时设置top,left,bottom,right.推荐以上写法,比较简洁.
        //layout.topSpace(10).leftSpace(10).bottomSpace(10).rightSpace(10);
    }];
    
    //蓝色view , 设置在superview里的距离和设置自身的宽高
    UIView *blueView = [UIView new];
    [bgView addSubview:blueView];
    blueView.backgroundColor = [UIColor blueColor];
    [blueView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.topSpace(20); //设置在superview里的上边距
        layout.leftSpace(20); //设置在superview里的左边距
        layout.rightSpace(20); //设置在superview里的右边距
        layout.heightValue(100); //设置高度
        // 注意:
        // 1.设置了左边距和右边距, 会自动拉升宽度,所以如上代码并没有设置宽度.
        // 2.如上代码可以写成一行,比如layout.topSpace(20).leftSpace(20)
        // 3.但是不推荐全部写在一行, 阅读性太差 , 而且在一行代码里写了诸多属性也不利于DEBUG
    }];
    
    //灰色view , 设置参照于其他view的距离和等宽等距离属性
    UIView *grayView = [UIView new];
    [bgView addSubview:grayView];
    grayView.backgroundColor = [UIColor grayColor];
    [grayView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        /*
         上边距参照blueview, 并加10的距离.
         意思就是说上边距在blueView的下边,并加上10的间距.
         如果只是想在blueview的下边没有距离的话, 第二个参数写为0即可
         */
        layout.topSpaceByView(blueView,10);
        
        /*
         左边距等同于blueView的左边距
         第二个参数是距离的值, 如果为0就代表左边距和blueview相等
         如果不为0,则先相等于blueview的距离,然后在加上第二参数的距离
         */
        layout.leftSpaceEqualTo(blueView,0);
        
        /*
         宽度等同于bluewView
         multiplier是倍数, 可选属性,如果不写此属性宽度就是等同于blueview
         如果写了此属性,如下示例, 则宽度等同于blueview的 0.5 倍
         */
        layout.widthEqualTo(blueView,0).multiplier(0.5);
        layout.heightValue(40); //设置高度
    }];
    
    //居中操作
    UIView *greenView = [UIView new];
    [bgView addSubview:greenView];
    greenView.backgroundColor = [UIColor greenColor];
    [greenView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.widthValue(40).heightValue(40); //设置宽高
        //在superview里保持居中
        layout.centerByView(greenView.superview);
        
        //如果要在blueview里保持居中写成如下即可.
        //注意如下代码打开的话,请把以上居中代码给注释掉,不然会有约束冲突
        //layout.centerByView(blueView);
        
        /*
         也可以单独的设置水平或者垂直居中
         */
        //在superview里水平居中
        //        layout.xCenterByView(greenView.superview);
        //在superview里垂直居中
        //        layout.yCenterByView(greenView.superview);
    }];
    
    //UILabel 的文字自适应
    UILabel *label = [UILabel new];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor purpleColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"这是文字自适应, 这是文字自适应 ,这是文字自适应 .这是文字自适应";
    [label zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        //设置上边距在grayView的下边,并且加10的距离
        layout.leftSpaceEqualTo(grayView,10);
        
        layout.bottomSpace(20); //设置在superview里的下边距
        
        layout.widthValue(100);//设置宽度
        
        layout.autoHeight(); //自适应高度,只针对UILabel有效
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    [btn setTitle:@"dismiss" forState:UIControlStateNormal];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
