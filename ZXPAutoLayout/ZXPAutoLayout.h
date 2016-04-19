//
//  ZXPAutoLayout.h
//  layout
/*
 
 ***************** ***************** ***************** *****************
 
 version : 1.3.5
 support : Xcode7.0以上 , iOS 7 以上
 简洁方便的autolayout, 打造天朝最优, 最简洁方便, 最容易上手的autolayout
 有任何问题或者需要改善交流的 可在 csdn博客或者github里给我提问题也可以联系我本人QQ
 github : https://github.com/biggercoffee/ZXPAutolayout
 csdn blog : http://blog.csdn.net/biggercoffee
 QQ : 974792506
 Email: z_xiaoping@163.com
 
 ***************** ***************** ***************** *****************
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
 *  top,left,bottom,right与某一个view的top,left,bottom,right相等
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^edgeEqualTo)(UIView *view);

/*
 居中操作,\
 第一个参数是参考某一个view进行居中
 第二个参数是参考某一个view居中过后在加上多少距离
 例子:
 layout.centerByView(superview); //在父视图中居中
 layout.centerByView(superview,100.0);//在父视图中居中并且x,y在累加100的距离
 其他用法同上~!
 */
//参考某一个view进行水平居中
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^xCenterByView)(UIView *view,CGFloat value);
//参考某一个view进行垂直居中
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^yCenterByView)(UIView *view,CGFloat value);
//参考某一个view进行居中
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^centerByView)(UIView *view,CGFloat value);

/*
 边距和宽高带有 EqualTo 或者 ByView 结尾的方法都带有两个参数.
 第一个参数为其他view
 第二个参数为在此基础之上累加的数值, 可传递可不传递,默认0. 接收浮点型
 公式: view(第一个参数) + 值(第二个参数)
 */

/*
 设置距离其它view的间距, 两个参数
 @param view  其它view
 @param ... 距离多少间距
 公式: view(第一个参数) + 值(第二个参数)
 
 例子:
 layout.topSpaceByView(otherView); //上边距离参考其他view, 也就是在某一个view的下边
 layout.topSpaceByView(otherView,100);//上边距离参考其他view, 也就是在某一个view的下边并且在累加100的距离
 其他用法同上~!
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^topSpaceByView)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^leftSpaceByView)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^bottomSpaceByView)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^rightSpaceByView)(UIView *view,CGFloat value);

/*
 @param view 设置view的距离参照与某一个view.有两个参数, 第一个是view, 第二个是value
 @param ...第二个参数
 如果第二个参数value 为0, 则距离等同于参照view的距离.
 如果第二个参数value不为0, 则在参照的view的基础之上加上这个参数的值
 公式 : 其他view的距离 + value
 例子: 同上~!
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^topSpaceEqualTo)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^leftSpaceEqualTo)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^bottomSpaceEqualTo)(UIView *view,CGFloat value);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^rightSpaceEqualTo)(UIView *view,CGFloat value);

/*
 设置宽高与其他view相等
 公式 : 其他view的宽或者高 + value
 @param view  其它view
 @param value 在参照的view的基础之上加上这个参数的值
 例子: 同上~!
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^widthEqualTo)(UIView *view,CGFloat value);
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^heightEqualTo)(UIView *view,CGFloat value);

/*
 设置宽高
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^widthValue)(CGFloat value);
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^heightValue)(CGFloat value);

/**
 根据文字自适应高度, 只针对UILabel控件生效. 最小值为0
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^autoHeight)();

/**
 根据最小值进行文字自适应高度, 只针对UILabel控件生效.
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^autoHeightByMin)(CGFloat value);

/**
 根据文字自适应宽度, 只针对UILabel控件生效. 最小值为0
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^autoWidth)();

/**
 根据最小值文字自适应宽度, 只针对UILabel控件生效.
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^autoWidthByMin)(CGFloat value);

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

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *top __deprecated_msg("use topSpace"); /**< 上边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *left __deprecated_msg("use leftSpace"); /**< 左边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *bottom __deprecated_msg("use bottomSpace"); /**< 下边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *right __deprecated_msg("use rightSpace"); /**< 右边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *leading __deprecated_msg("use leftSpace");
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *trailing __deprecated_msg("use rightSpace");

//居中
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *center __deprecated_msg("use centerByView");
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *centerX __deprecated_msg("use xCenterByView");
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *centerY __deprecated_msg("use yCenterByView");

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *width __deprecated_msg("use widthValue"); /**< 宽度 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *height __deprecated_msg("use heightValue"); /**< 高度 */

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *edges __deprecated_msg("use edgeInsets"); /**< add top,left,bottom, right */

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *with __deprecated_msg("不推荐使用");

//---- setting constraints
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^offset)(CGFloat offset) __deprecated_msg("不推荐使用"); /**< setting constant */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^equalTo)(id value) __deprecated_msg("不推荐使用"); /**< 如果是nsnumber类型就设置约束的值 , 如果是uiview类型就设置为相等于另一个view的约束 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^sizeOffset)(CGSize size) __deprecated_msg("不推荐使用"); /**< setting width,height */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^originOffset)(CGPoint origin) __deprecated_msg("不推荐使用"); /**< setting top,left */

@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^frameOffset)(CGRect frame) __deprecated_msg("不推荐使用");

@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^insets)(UIEdgeInsets insets) __deprecated_msg("不推荐使用");

//大于等于,小于等于
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^greaterThanOrEqual)(id value) __deprecated_msg("不推荐使用"); /**< 大于等于 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^lessThanOrEqual)(id value) __deprecated_msg("不推荐使用"); /**< 小于等于 */

@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^equalToWithMultiplier)(id value,CGFloat multiplier) __deprecated_msg("不推荐使用");

@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^greaterThanOrEqualWithMultiplier)(id value,CGFloat multiplier) __deprecated_msg("不推荐使用");

@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^lessThanOrEqualWithMultiplier)(id value,CGFloat multiplier) __deprecated_msg("不推荐使用");

@end

#pragma mark - category UIView + ZXPAdditions

@interface UIView (ZXPAdditions)

//attributes
@property (nonatomic,strong,readonly) id zxp_top __deprecated_msg("不推荐使用");
@property (nonatomic,strong,readonly) id zxp_left __deprecated_msg("不推荐使用");
@property (nonatomic,strong,readonly) id zxp_bottom __deprecated_msg("不推荐使用");
@property (nonatomic,strong,readonly) id zxp_right __deprecated_msg("不推荐使用");
@property (nonatomic,strong,readonly) id zxp_leading __deprecated_msg("不推荐使用");
@property (nonatomic,strong,readonly) id zxp_trailing __deprecated_msg("不推荐使用");
@property (nonatomic,strong,readonly) id zxp_width __deprecated_msg("不推荐使用");
@property (nonatomic,strong,readonly) id zxp_height __deprecated_msg("不推荐使用");
@property (nonatomic,strong,readonly) id zxp_centerX __deprecated_msg("不推荐使用");
@property (nonatomic,strong,readonly) id zxp_centerY __deprecated_msg("不推荐使用");

//add
- (void)zxp_addConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout;

//update
- (void)zxp_updateConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout;

//print
- (void)zxp_printConstraintsForSelf;

@end

#pragma mark - category UITableView + ZXPCellAutoHeight

@interface UITableView (ZXPCellAutoHeight)

/**
 *  cell的高度自适应, 在tableView: cellForRowAtIndexPath: 方法里请用
 [tableView dequeueReusableCellWithIdentifier:cellid];
 方式获取cell
 
 请不要使用
 [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
 会造成野指针错误
 *
 *  @param indexPath indexPath
 *
 *  @return 返回cell.contentView的子视图里 y+height 最大值的数值
 */
- (CGFloat)zxp_cellHeightWithindexPath:(NSIndexPath *)indexPath;

/**
 *   cell的高度自适应, 在tableView: cellForRowAtIndexPath: 方法里请用
 [tableView dequeueReusableCellWithIdentifier:cellid];
 方式获取cell
 
 请不要使用
 [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
 会造成野指针错误
 *
 *  @param indexPath indexPath
 *  @param block     block
 *
 *  @return 返回block里return view的 y+height
 */
- (CGFloat)zxp_cellHeightWithindexPath:(NSIndexPath *)indexPath bottomView:(UIView *(^)(__kindof UITableViewCell *cell))block;

/**
 *   cell的高度自适应, 在tableView: cellForRowAtIndexPath: 方法里请用
 [tableView dequeueReusableCellWithIdentifier:cellid];
 方式获取cell
 
 请不要使用
 [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
 会造成野指针错误
 *
 *  @param indexPath indexPath
 *  @param block     block
 *  @param space     space
 *
 *  @return 返回block里return view的 y+height+space
 */
- (CGFloat)zxp_cellHeightWithindexPath:(NSIndexPath *)indexPath bottomView:(UIView *(^)(__kindof UITableViewCell *cell))block space:(CGFloat)space;;

/**
 *   cell的高度自适应, 在tableView: cellForRowAtIndexPath: 方法里请用
 [tableView dequeueReusableCellWithIdentifier:cellid];
 方式获取cell
 
 请不要使用
 [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
 会造成野指针错误
 *
 *  @param indexPath indexPath
 *  @param space     space
 *
 *  @return 返回cell.contentView的子视图里 y+height 最大值的数值 并且加上space参数的值
 */
- (CGFloat)zxp_cellHeightWithindexPath:(NSIndexPath *)indexPath space:(CGFloat)space;

@end








