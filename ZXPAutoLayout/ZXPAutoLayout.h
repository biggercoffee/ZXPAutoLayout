//
//  ZXPAutoLayout.h
//  layout
/*
 
    version : 1.0.0
    support : Xcode7.0以上 , iOS 7 以上
    简洁方便的autolayout, 打造天朝最优, 最简洁方便, 最容易上手的autolayout
    有任何问题或者需要改善交流的 可在博客或者github里给我提问题也可以联系我本人QQ
    github : https://github.com/biggercoffee/ZXPAutolayout
    csdn blog : http://blog.csdn.net/biggercoffee
    QQ : 974792506
 
 */
//  Created by coffee on 15/10/10.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZXPStackViewType) {
    /**
     *  水平对齐
     */
    ZXPStackViewTypeHorizontal = 1,
    /**
     *  垂直对齐
     */
    ZXPStackViewTypeVertical
};

#pragma mark - ZXPStackView class

@interface ZXPStackView : UIView

/**
 *  内边距
 */
@property (assign,nonatomic) UIEdgeInsets padding;

/**
 *  view之间的距离
 */
@property (assign,nonatomic) CGFloat space;

/**
 *  根据对齐类型进行布局
 *
 *  @param type ZXPStackViewTypeHorizontal or ZXPStackViewTypeVertical
 */
- (void)layoutWithType:(ZXPStackViewType)type;

@end

#pragma mark - ZXPAutoLayoutMaker class

@interface ZXPAutoLayoutMaker : NSObject

/*
    设置在superview里的距离
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^topSpace)(CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^leftSpace)(CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^bottomSpace)(CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^rightSpace)(CGFloat value);

/**
 *  设置在superview里的top,left,bottom,right的间距
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^edgeInsets)(UIEdgeInsets insets);

/**
 *  设置在superview里的top,left,bottom,right与某一个view的top,left,bottom,right相等
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^edgeEqualTo)(UIView *view);

/*
    居中操作
 */
//参考某一个view进行水平居中
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^xCenterByView)(UIView *view);
//参考某一个view进行垂直居中
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^yCenterByView)(UIView *view);
//参考某一个view进行居中
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^centerByView)(UIView *view);

/*
    边距和宽高带有 EqualTo 或者 ByView 结尾的方法都带有两个参数.
    第一个参数为其他view
    第二个参数为在此基础之上累加的数值
*/

/*
    设置距离其它view的间距, 两个参数
    @param view  其它view
    @param value 距离多少间距
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^topSpaceByView)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^leftSpaceByView)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^bottomSpaceByView)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^rightSpaceByView)(UIView *view,CGFloat value);

/*
    设置view的距离参照与某一个view.有两个参数, 第一个是view, 第二个是value
    如果第二个参数value 为0, 则距离等同于参照view的距离.
    如果第二个参数value不为0, 则在参照的view的基础之上加上这个参数的值
    公式 : 其他view的距离 + value
    @param view  其它view
    @param value 距离多少间距,如果要与其他view距离保持一样,此数值写为0即可. 
                 如果要在其他view的距离基础之上在加100的距离, 此数值就写成100即可
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^topSpaceEqualTo)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^leftSpaceEqualTo)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^bottomSpaceEqualTo)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^rightSpaceEqualTo)(UIView *view,CGFloat value);

/*
 设置宽高与其他view相等
 公式 : 其他view的宽或者高 + value
 @param view  其它view
 @param value 值
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^widthEqualTo)(UIView *view,CGFloat value);
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^heightEqualTo)(UIView *view,CGFloat value);

/*
    设置宽高
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^widthValue)(CGFloat value);
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^heightValue)(CGFloat value);

/**
    根据文字自适应高度, 只针对UILabel控件生效.
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^autoHeight)();

/**
 *  优先级
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^priority)(UILayoutPriority priority);

/**
 *  倍数,原始值的多少倍,此函数只针对最后一次设置的约束生效,
    例如: layout.topSpace(10).leftSpace(10).widthEqualTo(view1).multiplier(0.5).heightValue(40);
    在这行代码里的倍数,只针对宽度生效,表示宽度是view1宽度的0.5倍.
    如果想给多个属性增加倍数,则在对应的后面写上multiplier属性即可
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^multiplier)(CGFloat multiplier);

//init
- (instancetype)initWithView:(UIView *)view type:(id)type;

#pragma mark - deprecated apis

// ---------------- 以下是1.0以前的布局方式, 不推荐使用 -------------------

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *top; /**< 上边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *left; /**< 左边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *bottom; /**< 下边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *right; /**< 右边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *leading;
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *trailing;

//居中
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *center;
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *centerX;
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *centerY;

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *width; /**< 宽度 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *height; /**< 高度 */

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *edges; /**< add top,left,bottom, right */

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *with;

//---- setting constraints
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^offset)(CGFloat offset); /**< setting constant */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^equalTo)(id value); /**< 如果是nsnumber类型就设置约束的值 , 如果是uiview类型就设置为相等于另一个view的约束 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^sizeOffset)(CGSize size); /**< setting width,height */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^originOffset)(CGPoint origin); /**< setting top,left */

@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^frameOffset)(CGRect frame);

@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^insets)(UIEdgeInsets insets);

//大于等于,小于等于
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^greaterThanOrEqual)(id value); /**< 大于等于 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^lessThanOrEqual)(id value); /**< 小于等于 */

@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^equalToWithMultiplier)(id value,CGFloat multiplier);

@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^greaterThanOrEqualWithMultiplier)(id value,CGFloat multiplier);

@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^lessThanOrEqualWithMultiplier)(id value,CGFloat multiplier);

@end

#pragma mark - category UIView + ZXPAdditions

@interface UIView (ZXPAdditions)

//attributes
@property (nonatomic,strong,readonly) id zxp_top;
@property (nonatomic,strong,readonly) id zxp_left;
@property (nonatomic,strong,readonly) id zxp_bottom;
@property (nonatomic,strong,readonly) id zxp_right;
@property (nonatomic,strong,readonly) id zxp_leading;
@property (nonatomic,strong,readonly) id zxp_trailing;
@property (nonatomic,strong,readonly) id zxp_width;
@property (nonatomic,strong,readonly) id zxp_height;
@property (nonatomic,strong,readonly) id zxp_centerX;
@property (nonatomic,strong,readonly) id zxp_centerY;

//add
- (void)zxp_addConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout;

//update
- (void)zxp_updateConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout;

//print
- (void)zxp_printConstraintsForSelf;

@end






