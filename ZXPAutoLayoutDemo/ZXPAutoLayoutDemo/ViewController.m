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
    
    //等宽, 水平对齐 第一种方式
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
    
    //等宽, 水平对齐 第二种方式
    // ZXPStackView 的使用
    {
        ZXPStackView *stackView = [ZXPStackView new];
        [self.view addSubview:stackView];
        stackView.backgroundColor = [UIColor blackColor];
        
        //只需要设置stackView的宽高和位置即可
        [stackView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.topSpaceByView(grayView,20);
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
        //调用此方法会给subviews自动添加约束条件,进行等宽或者等高排列
        [stackView layoutWithType:ZXPStackViewTypeHorizontal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  @author coffee
 *
 *  @brief 1.0之前的布局方式, 不推荐使用
 */
- (void)oldLayout {
    /*
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
     */
}

@end
