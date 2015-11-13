//
//  ZXPAutoLayout.h
//  layout
/*
 
    version : 0.1.0
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

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *top; /**< 上边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *left; /**< 左边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *bottom; /**< 下边距 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *right; /**< 右边距 */

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *width; /**< 宽度 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *height; /**< 高度 */

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *edges; /**< 设置上下左右边距 */

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *with;

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^offset)(CGFloat offset); /**< 设置约束的值 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^equalTo)(id value); /**< 如果是nsnumber类型就设置约束的值 , 如果是uiview类型就设置为相等于另一个view的约束 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^size)(CGSize size); /**< 约束大小 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^origin)(CGPoint origin); /**< 约束位置,以左上角为原点 */

//居中
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^center)(UIView *view);
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^centerX)(UIView *view);
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^centerY)(UIView *view);

@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^greaterThanOrEqual)(id value); /**< 大于等于 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^lessThanOrEqual)(id value); /**< 小于等于 */

/**
 *  @author coffee
 *
 *  等比例设置值,
    value : nsnumber or uiview
    multiplier : 0 -- 1
 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^equalToWithMultiplier)(id value,CGFloat multiplier);

/**
 *  @author coffee
 *
 *  等比例设置值,并且大于等于这个值
    value : nsnumber or uiview
    multiplier : 0 -- 1
 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^greaterThanOrEqualWithMultiplier)(id value,CGFloat multiplier);

/**
 *  @author coffee
 *
 *  等比例设置值,并且小于等于这个值
    value : nsnumber or uiview
    multiplier : 0 -- 1
 */
@property (strong, nonatomic, readonly) ZXPAutoLayoutMaker *(^lessThanOrEqualWithMultiplier)(id value,CGFloat multiplier);

- (instancetype)initWithView:(UIView *)view type:(id)type;

@end

#pragma mark - category

@interface UIView (ZXPAdditions)

//view 的边距属性
@property (nonatomic,strong,readonly) UIView *zxp_top;
@property (nonatomic,strong,readonly) UIView *zxp_left;
@property (nonatomic,strong,readonly) UIView *zxp_bottom;
@property (nonatomic,strong,readonly) UIView *zxp_right;

@property (nonatomic,assign,readonly) NSLayoutAttribute zxp_attribute;

/**
 *  @author coffee
 *
 *  添加约束
 *
 *  @param layout layout description
 */
- (void)zxp_addConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout;

/**
 *  @author coffee
 *
 *  更新约束
 *
 *  @param layout layout description
 */
- (void)zxp_updateConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout;

@end






