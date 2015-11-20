//
//  ZXPAutoLayout.h
//  layout
/*
 
    version : 0.3.0
    support : Xcode7.0以上 , iOS 7 以上
    简洁方便的autolayout,有任何问题欢迎issue 我
    github : https://github.com/biggercoffee/ZXPAutolayout
    QQ : 974792506
 
 */
//  Created by coffee on 15/10/10.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ZXPAutoLayoutMaker : NSObject

//--- constraint attributes
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *top; /**< 上边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *left; /**< 左边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *bottom; /**< 下边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *right; /**< 右边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *leading;
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *trailing;

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *width; /**< 宽度 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *height; /**< 高度 */

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *edges; /**< 设置上下左右边距 */

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *with;

//---- setting constraints
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^offset)(CGFloat offset); /**< 设置约束的值 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^equalTo)(id value); /**< 如果是nsnumber类型就设置约束的值 , 如果是uiview类型就设置为相等于另一个view的约束 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^size)(CGSize size); /**< 约束大小 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^origin)(CGPoint origin); /**< 约束位置,以左上角为原点 */

/**
 *  @author coffee
 *
 *  @brief  setting top,left,width,height
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^frame)(CGRect frame);

/**
 *  @author coffee
 *
 *  @brief  setting top,left,bottom,right
 */
@property (copy,nonatomic,readonly) ZXPAutoLayoutMaker *(^insets)(UIEdgeInsets insets);

//优先级和比例
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^priority)(UILayoutPriority priority);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^multiplier)(CGFloat multiplier);

//居中
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^center)(UIView *view);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^centerX)(UIView *view);
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^centerY)(UIView *view);

//大于等于,小于等于
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^greaterThanOrEqual)(id value); /**< 大于等于 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^lessThanOrEqual)(id value); /**< 小于等于 */

//------带有两个参数的block:约束and比例
/**
 *  @author coffee
 *
 *  等比例设置值,
    value : nsnumber or uiview
    multiplier : 0 -- 1
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^equalToWithMultiplier)(id value,CGFloat multiplier);

/**
 *  @author coffee
 *
 *  等比例设置值,并且大于等于这个值
    value : nsnumber or uiview
    multiplier : 0 -- 1
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^greaterThanOrEqualWithMultiplier)(id value,CGFloat multiplier);

/**
 *  @author coffee
 *
 *  等比例设置值,并且小于等于这个值
    value : nsnumber or uiview
    multiplier : 0 -- 1
 */
@property (copy, nonatomic, readonly) ZXPAutoLayoutMaker *(^lessThanOrEqualWithMultiplier)(id value,CGFloat multiplier);

//init
- (instancetype)initWithView:(UIView *)view type:(id)type;

@end

#pragma mark - category

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

- (void)zxp_printConstraintsForSelf;

@end






