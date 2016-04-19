//
//  ZXPAutoLayout.m
//  layout
//
//  Created by coffee on 15/10/10.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import "ZXPAutoLayout.h"
#import <objc/runtime.h>

static NSString * const kZXPAutoLayoutMakerAdd = @"ZXPAutoLayoutMakerAdd-zxp";
static NSString * const kZXPAutoLayoutMakerUpdate = @"ZXPAutoLayoutMakerUpdate-zxp";
static NSString * const kZXPAttributeKey = @"ZXPAttributeKey-zxp";

#pragma mark - private category of array

@interface NSArray (ZXPPrivateOfAutoLayout)

- (NSArray *)distinctUnionOfObjects;

@end

@implementation NSArray (ZXPPrivateOfAutoLayout)

- (NSArray *)distinctUnionOfObjects {
    return [self valueForKeyPath:@"@distinctUnionOfObjects.self"];
}

@end

#pragma mark - ZXPStackView class

@implementation ZXPStackView

- (void)layoutWithType:(ZXPStackViewType)type {
    NSInteger subviewCount = self.subviews.count;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [obj zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            if (type == ZXPStackViewTypeHorizontal) { //水平
                if (!idx) {
                    layout.leftSpace(self.padding.left);
                }
                else {
                    layout.leftSpaceByView(self.subviews[idx - 1],self.space);
                }
                if (subviewCount - 1 == idx) {
                    layout.rightSpace(self.padding.right);
                }
                else {
                    layout.widthEqualTo(self.subviews[idx + 1],0);
                }
                layout.topSpace(self.padding.top);
                layout.bottomSpace(self.padding.bottom);
            }
            else if (type == ZXPStackViewTypeVertical) { //垂直
                if (!idx) {
                    layout.topSpace(self.padding.top);
                }
                else {
                    layout.topSpaceByView(self.subviews[idx - 1],self.space);
                }
                
                if (subviewCount - 1 == idx) {
                    layout.bottomSpace(self.padding.bottom);
                }
                else {
                    layout.heightEqualTo(self.subviews[idx + 1],0);
                }
                layout.leftSpace(self.padding.left);
                layout.rightSpace(self.padding.right);
            }
        }];
    }];
    
}

@end

#pragma mark - ZXPAutoLayoutMaker class

@interface ZXPAutoLayoutMaker ()

@property (nonatomic,strong) NSMutableArray *constraintAttributes;

@property (nonatomic,strong) NSMutableArray<NSLayoutConstraint *> *tempRelatedConstraints;

@property (nonatomic,strong) UIView *view;
@property (nonatomic,strong) NSLayoutConstraint *lastConstraint;
@property (nonatomic,assign) id layoutType;

@end

@implementation ZXPAutoLayoutMaker

+ (void)load {
    
    //-------- 已废弃, 保留1.0之前的api实现 --------
    NSMutableArray<NSString *> *layoutAttributeStringList = [NSMutableArray array];
    NSMutableArray<NSNumber *> *layoutAttributeValueList = [NSMutableArray array];
#define enumToString(value) [layoutAttributeStringList addObject:@#value]; \
[layoutAttributeValueList addObject:@(value)];
    enumToString(NSLayoutAttributeLeft)
    enumToString(NSLayoutAttributeRight)
    enumToString(NSLayoutAttributeTop)
    enumToString(NSLayoutAttributeBottom)
    enumToString(NSLayoutAttributeLeading)
    enumToString(NSLayoutAttributeTrailing)
    enumToString(NSLayoutAttributeWidth)
    enumToString(NSLayoutAttributeHeight)
    enumToString(NSLayoutAttributeCenterX)
    enumToString(NSLayoutAttributeCenterY)
#undef enumToString
    
    objc_setAssociatedObject([self class], @selector(swizzleMethodForAttribute),
                             @{@"keys":layoutAttributeStringList,
                               @"values":layoutAttributeValueList},
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSArray<NSString *> *methods = @[NSStringFromSelector(@selector(top)),
                                     NSStringFromSelector(@selector(left)),
                                     NSStringFromSelector(@selector(bottom)),
                                     NSStringFromSelector(@selector(right)),
                                     NSStringFromSelector(@selector(width)),
                                     NSStringFromSelector(@selector(height)),
                                     NSStringFromSelector(@selector(centerX)),
                                     NSStringFromSelector(@selector(centerY)),
                                     NSStringFromSelector(@selector(center))];
    
    [methods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL aSel = NSSelectorFromString(obj);
        method_setImplementation(
                                 class_getInstanceMethod(ZXPAutoLayoutMaker.class,aSel),
                                 class_getMethodImplementation(ZXPAutoLayoutMaker.class, @selector(swizzleMethodForAttribute)));
    }];
    //---------- 以上是已废弃的代码, 保留1.0之前的api实现 --------------
}

#pragma mark - swizzle
/**
 *  @author coffee
 *
 *  @brief 已废弃,保留1.0之前的api接口实现
 *
 *  @return self
 */
- (id)swizzleMethodForAttribute  __deprecated_msg("过期") {
    
    NSString *methodName = NSStringFromSelector(_cmd);
    if ([methodName isEqualToString:@"center"]) {
        return self.centerByView(self.view.superview,0);
    }
    
    //remove tempRelatedConstraints
    [self.tempRelatedConstraints removeAllObjects];
    
    //get data for attributes
    NSDictionary *attributeData = objc_getAssociatedObject([self class], @selector(swizzleMethodForAttribute));
    NSMutableArray<NSString *> *layoutAttributeStringList = attributeData[@"keys"];
    NSMutableArray<NSNumber *> *layoutAttributeValueList = attributeData[@"values"];
    
    //get attribute for this
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self endswith[c] %@",methodName];
    NSString *layoutAttributeString = [layoutAttributeStringList filteredArrayUsingPredicate:predicate].firstObject;
    NSUInteger index = [layoutAttributeStringList indexOfObject:layoutAttributeString];
    
    //add constraints attribute
    [self.constraintAttributes addObject:layoutAttributeValueList[index]];
    
    return self;
}

#pragma mark - public

- (instancetype)initWithView:(UIView *)view type:(id)type {
    
    if (self = [super init]) {
        
        self.constraintAttributes = [NSMutableArray array];
        self.tempRelatedConstraints = [NSMutableArray array];
        
        self.view = view;
        self.layoutType = type;
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return self;
}

#pragma mark 设置在superview里的距离

- (ZXPAutoLayoutMaker *(^)(CGFloat))topSpace {
    return ^(CGFloat value) {
        return [self p_addOrUpdateSpaceInSuperview:NSLayoutAttributeTop constant:value];
    };
}

- (ZXPAutoLayoutMaker *(^)(CGFloat))leftSpace {
    return ^(CGFloat value) {
        return [self p_addOrUpdateSpaceInSuperview:NSLayoutAttributeLeft constant:value];
    };
}

- (ZXPAutoLayoutMaker *(^)(CGFloat))bottomSpace {
    return ^(CGFloat value) {
        return [self p_addOrUpdateSpaceInSuperview:NSLayoutAttributeBottom constant:value];
    };
}

- (ZXPAutoLayoutMaker *(^)(CGFloat))rightSpace {
    return ^(CGFloat value) {
        return [self p_addOrUpdateSpaceInSuperview:NSLayoutAttributeRight constant:value];
    };
}

- (ZXPAutoLayoutMaker *(^)(UIEdgeInsets))edgeInsets {
    return ^(UIEdgeInsets edge) {
        return self.topSpace(edge.top).leftSpace(edge.left).bottomSpace(edge.bottom).rightSpace(edge.right);
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *))edgeEqualTo {
    return ^(UIView *view) {
        return self.topSpaceEqualTo(view,0).leftSpaceEqualTo(view,0).bottomSpaceEqualTo(view,0).rightSpaceEqualTo(view,0);
    };
}

#pragma mark 居中

- (ZXPAutoLayoutMaker *(^)(UIView *,CGFloat))xCenterByView {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeCenterX multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *,CGFloat))yCenterByView {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeCenterY multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *,CGFloat))centerByView {
    return ^(UIView *view,CGFloat value) {
        return self.xCenterByView(view,value).yCenterByView(view,value);
    };
}

#pragma mark 设置距离其它view的间距
/*
 @param view  其它view
 @param value 距离多少间距
 */

- (ZXPAutoLayoutMaker *(^)(UIView *, CGFloat))topSpaceByView {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeBottom multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *, CGFloat))leftSpaceByView {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeRight multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *, CGFloat))bottomSpaceByView {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeTop multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *,CGFloat))rightSpaceByView {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeLeft multiplier:1 constant:value];
        return self;
    };
}

#pragma mark 设置距离与其他view相等

- (ZXPAutoLayoutMaker *(^)(UIView *, CGFloat))topSpaceEqualTo {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeTop multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *, CGFloat))leftSpaceEqualTo {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeLeft multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *, CGFloat))bottomSpaceEqualTo {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeBottom multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *, CGFloat))rightSpaceEqualTo {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeRight multiplier:1 constant:value];
        return self;
    };
}

#pragma mark 设置宽高

- (ZXPAutoLayoutMaker *(^)(CGFloat))widthValue {
    return ^(CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual secondView:nil secondAttribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(CGFloat))heightValue {
    return ^(CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual secondView:nil secondAttribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *,CGFloat))widthEqualTo {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeWidth multiplier:1 constant:value];
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *,CGFloat))heightEqualTo {
    return ^(UIView *view,CGFloat value) {
        [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual secondView:view secondAttribute:NSLayoutAttributeHeight multiplier:1 constant:value];
        return self;
    };
}

#pragma mark 自适应宽高

- (ZXPAutoLayoutMaker *(^)())autoHeight {
    return ^() {
        return self.autoHeightByMin(0);
    };
}

- (ZXPAutoLayoutMaker *(^)(CGFloat))autoHeightByMin {
    return ^(CGFloat value) {
        if ([self.view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *) self.view;
            label.numberOfLines = 0;
            [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual secondView:nil secondAttribute:NSLayoutAttributeHeight multiplier:1 constant:value];
        }
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)())autoWidth {
    return ^() {
        return self.autoWidthByMin(0);
    };
}

- (ZXPAutoLayoutMaker *(^)(CGFloat))autoWidthByMin {
    return ^(CGFloat value) {
        if ([self.view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *) self.view;
            NSInteger line = label.numberOfLines;
            label.numberOfLines = line > 0 ? line : 1;
            [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual secondView:nil secondAttribute:NSLayoutAttributeWidth multiplier:1 constant:value];
        }
        return self;
    };
}

#pragma mark - deprecated public
//--------以下方法都过期不推荐使用-------------

- (ZXPAutoLayoutMaker *)with {
    [self.tempRelatedConstraints removeAllObjects];
    return self;
}

- (ZXPAutoLayoutMaker *)edges {
    return self.top.left.bottom.right;
}

- (ZXPAutoLayoutMaker *(^)(CGFloat))offset {
    return ^(CGFloat offset) {
        return [self setupConstraint:offset relatedBy:NSLayoutRelationEqual multiplierBy:1.0];
    };
}

- (ZXPAutoLayoutMaker *(^)(id))greaterThanOrEqual {
    return ^(id value) {
        return self.greaterThanOrEqualWithMultiplier(value,1.0);
    };
}

- (ZXPAutoLayoutMaker *(^)(id))lessThanOrEqual {
    return ^(id value) {
        return self.lessThanOrEqualWithMultiplier(value,1.0);
    };
}

- (ZXPAutoLayoutMaker *(^)(id ))equalTo {
    return ^(id value) {
        return self.equalToWithMultiplier(value,1.0);
    };
}

- (ZXPAutoLayoutMaker *(^)(CGSize))sizeOffset {
    return ^(CGSize size) {
        self.width.offset(size.width);
        self.height.offset(size.height);
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(CGPoint))originOffset {
    return ^(CGPoint origin) {
        self.top.offset(origin.y);
        self.left.offset(origin.x);
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(CGRect))frameOffset {
    return ^(CGRect frame) {
        return self.top.offset(CGRectGetMinY(frame)).left.offset(CGRectGetMinX(frame)).width.offset(CGRectGetWidth(frame)).height.offset(CGRectGetHeight(frame));
    };
}

- (ZXPAutoLayoutMaker *(^)(UIEdgeInsets))insets {
    return ^(UIEdgeInsets insets) {
        return self.top.offset(insets.top).left.offset(insets.left).bottom.offset(insets.bottom).right.offset(insets.right);
    };
}

- (ZXPAutoLayoutMaker *(^)(UILayoutPriority))priority {
    return ^(UILayoutPriority priority) {
        self.lastConstraint.priority = priority;
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(CGFloat))multiplier {
    return ^(CGFloat multiplier) {
        if (self.lastConstraint) {
            [self.view.superview removeConstraint:self.lastConstraint];
            NSLayoutConstraint *obj = self.lastConstraint;
            [self.view.superview addConstraint:[NSLayoutConstraint constraintWithItem:obj.firstItem attribute:obj.firstAttribute relatedBy:obj.relation toItem:obj.secondItem attribute:obj.secondAttribute multiplier:multiplier constant:obj.constant]];
        }
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(id, CGFloat))equalToWithMultiplier {
    return ^(id value,CGFloat multiplier) {
        return [self reAddConstraint:value relatedBy:NSLayoutRelationEqual multiplier:multiplier];
    };
}

- (ZXPAutoLayoutMaker *(^)(id, CGFloat))greaterThanOrEqualWithMultiplier {
    return ^(id value,CGFloat multiplier){
        return [self reAddConstraint:value relatedBy:NSLayoutRelationGreaterThanOrEqual multiplier:multiplier];
    };
}

- (ZXPAutoLayoutMaker *(^)(id, CGFloat))lessThanOrEqualWithMultiplier {
    return ^(id value,CGFloat multiplier) {
        return [self reAddConstraint:value relatedBy:NSLayoutRelationLessThanOrEqual multiplier:multiplier];
    };
}

#pragma mark - private methods

- (id)p_addOrUpdateSpaceInSuperview:(NSLayoutAttribute) attribute constant:(CGFloat)constant {
    [self p_addOrUpdateConstraintWithFristView:self.view firstAttribute:attribute relatedBy:NSLayoutRelationEqual secondView:nil secondAttribute:attribute multiplier:1 constant:constant];
    return self;
}

/**
 *  @author coffee
 *
 *  @brief 添加or更新 约束
 *
 *  @param firstView       第一个view
 *  @param firstAttribute  第一个view的属性
 *  @param relation        关系(等于,大于等于,小于等于)
 *  @param secondView      第二个view
 *  @param secondAttribute 第二个view的属性
 *  @param multiplier      比例 ( 0 -- 1 )
 *  @param constant        约束的值
 */
- (void)p_addOrUpdateConstraintWithFristView:(UIView *)firstView firstAttribute:(NSLayoutAttribute)firstAttribute relatedBy:(NSLayoutRelation)relation secondView:(UIView *)secondView secondAttribute:(NSLayoutAttribute)secondAttribute multiplier:(CGFloat)multiplier constant:(CGFloat)constant {
    
    if (self.layoutType == kZXPAutoLayoutMakerAdd) {
        
        NSAssert(self.view.superview, @"请先添加superview : %@",self.view);
        
        [self p_addConstraintWithFristView:firstView firstAttribute:firstAttribute relatedBy:relation secondView:secondView secondAttribute:secondAttribute multiplier:multiplier constant:constant];
    }
    else { //update
        
        if (secondView) {
            [self.view.superview.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (obj.firstItem == self.view && obj.firstAttribute == firstAttribute) {
                    [self.view.superview removeConstraint:obj]; //remove
                }
                
            }];
            [self p_addConstraintWithFristView:firstView firstAttribute:firstAttribute relatedBy:relation secondView:secondView secondAttribute:secondAttribute multiplier:multiplier constant:constant];
        }
        else {
            [self p_updateConstraintWithFirstView:self.view firstAttribute:firstAttribute constant:constant];
        }
    }
    
}

- (void)p_addConstraintWithFristView:(UIView *)firstView firstAttribute:(NSLayoutAttribute)firstAttribute relatedBy:(NSLayoutRelation)relation secondView:(UIView *)secondView secondAttribute:(NSLayoutAttribute)secondAttribute multiplier:(CGFloat)multiplier constant:(CGFloat)constant {
    id view = nil;
    id toItem = nil;
    CGFloat value = firstAttribute == NSLayoutAttributeBottom || firstAttribute == NSLayoutAttributeRight ? 0.0 - constant : constant;
    
    if (firstAttribute == NSLayoutAttributeWidth || firstAttribute == NSLayoutAttributeHeight) {
        if (secondView) {
            view = firstView.superview;
            toItem = secondView?:firstView.superview;
        }
        else {
            view = firstView;
        }
    }
    else {
        view = firstView.superview;
        toItem = secondView?:firstView.superview;
    }
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:firstView
                                                                  attribute:firstAttribute
                                                                  relatedBy:relation
                                                                     toItem:toItem
                                                                  attribute:secondAttribute
                                                                 multiplier:multiplier
                                                                   constant:value];
    self.lastConstraint = constraint;
    [view addConstraint:constraint];
}

- (void)p_updateConstraintWithFirstView:(UIView *)view firstAttribute:(NSLayoutAttribute)attribute constant:(CGFloat)constant {
    
    NSArray<__kindof NSLayoutConstraint *> *constraints = attribute == NSLayoutAttributeWidth || attribute == NSLayoutAttributeHeight ? view.constraints : view.superview.constraints;
    [constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (attribute == NSLayoutAttributeLeft) {
            if (obj.firstItem == self.view && (obj.firstAttribute == attribute || obj.firstAttribute == NSLayoutAttributeLeading)) {
                obj.constant = constant;
                *stop = YES;
            }
        }
        else if (attribute == NSLayoutAttributeRight) {
            *stop = [self p_updateRightOrBottomWithConstraint:obj firstAttr:NSLayoutAttributeTrailing secondAttr:attribute constant:constant];
        }
        else if (attribute == NSLayoutAttributeBottom) {
            *stop = [self p_updateRightOrBottomWithConstraint:obj firstAttr:NSLayoutAttributeBottom secondAttr:attribute constant:constant];
        }
        else {
            if (obj.firstItem == view && obj.firstAttribute == attribute) {
                obj.constant = constant;
                *stop = YES;
            }
        }
    }];
    
    [self.view layoutIfNeeded];
    
}

- (BOOL)p_updateRightOrBottomWithConstraint:(NSLayoutConstraint *)obj firstAttr:(NSLayoutAttribute)firstAttr secondAttr:(NSLayoutAttribute)secondAttr constant:(CGFloat)constant {
    
    //更新ib里添加的约束, 右边距和下边距要特殊处理
    BOOL ibConstant = (obj.firstItem == self.view.superview && obj.firstAttribute == firstAttr ) && (obj.secondItem == self.view && obj.secondAttribute == firstAttr);
    if ( ibConstant ) { //ib添加的约束
        obj.constant = constant;
        return YES;
    }
    else if ( obj.firstItem == self.view && obj.firstAttribute == secondAttr ) { // ZXPAutoLayout添加的约束
        obj.constant = 0.0 - constant;
        return YES;
    }
    return NO;
}

#pragma mark - deprecated private methods , 保留1.0之前的api所使用的私有方法.

- (id)reAddConstraint:(id)value relatedBy:(NSLayoutRelation)relateBy multiplier:(CGFloat)multiplier {
    if ([value isKindOfClass:[NSNumber class]]) {
        return [self setupConstraint:[value floatValue] relatedBy:relateBy multiplierBy:multiplier];
    }
    else if ([value isKindOfClass:[UIView class]]) {
        return [self reAddConstraintOfAttributesWithToItem:value relatedBy:relateBy multiplierBy:multiplier];
    }
    NSAssert(NO, @"%@ : Does not supper type",self.view);
    return self;
}

- (ZXPAutoLayoutMaker *)setupConstraint:(CGFloat)offset relatedBy:(NSLayoutRelation)related multiplierBy:(CGFloat)multiplier {
    
    if (!self.view.superview) {
        NSAssert(NO, @"%@ , not superview",self.view.class);
        return self;
    }
    
    if (self.tempRelatedConstraints.count) {
        
        for (NSLayoutConstraint *constraint in self.tempRelatedConstraints) { //update constant in tempRelatedConstraints
            constraint.constant = offset;
        }
        
        //clear
        [self.tempRelatedConstraints removeAllObjects];
        [self.constraintAttributes removeAllObjects];
        
        return self;
    }
    
    NSArray *array = [self.constraintAttributes distinctUnionOfObjects];
    for (id attribute in array) {
        
        NSLayoutAttribute firstAttribute = [attribute integerValue];
        
        if ( self.layoutType == kZXPAutoLayoutMakerAdd ) {
            
            id view = nil;
            id toItem = nil;
            NSLayoutAttribute secondAttribute = NSLayoutAttributeNotAnAttribute;
            
            if (firstAttribute == NSLayoutAttributeWidth || firstAttribute == NSLayoutAttributeHeight) {
                view = self.view;
            }
            else {
                view = self.view.superview;
                toItem = self.view.superview;
                secondAttribute = firstAttribute;
            }
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                             attribute:firstAttribute
                                                             relatedBy:related
                                                                toItem:toItem
                                                             attribute:secondAttribute
                                                            multiplier:multiplier
                                                              constant:offset]];
            
        }
        else { //update
            [self p_updateConstraintWithFirstView:self.view firstAttribute:firstAttribute constant:offset];
        }
        
    } //end for
    
    //clear attributes in array
    [self.constraintAttributes removeAllObjects];
    
    return self;
}

- (ZXPAutoLayoutMaker *)reAddConstraintOfAttributesWithToItem:(UIView *)secondView relatedBy:(NSLayoutRelation)related multiplierBy:(CGFloat)multiplier {
    
    if (!self.view.superview) {
        NSAssert(NO, @"%@ , not superview",self.view.class);
        return self;
    }
    
    NSArray *distinctUnionAttributes = [self.constraintAttributes distinctUnionOfObjects];
    NSLayoutAttribute secondAttribute = [objc_getAssociatedObject(secondView, &kZXPAttributeKey) integerValue];
    
    if (self.layoutType == kZXPAutoLayoutMakerUpdate) { //如果是更新约束,就先删掉view对应的相对约束
        [self.view.superview.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            for (id attribute in distinctUnionAttributes) {
                if (obj.firstItem == self.view && obj.firstAttribute == [attribute integerValue]) {
                    [self.view.superview removeConstraint:obj]; //remove
                }
            }
            
        }];
    }
    
    for (id attribute in distinctUnionAttributes) {
        NSLayoutAttribute firstAttribute = [attribute integerValue];
        NSLayoutAttribute toAttribute = secondAttribute != NSLayoutAttributeNotAnAttribute ? secondAttribute : firstAttribute;
        
        //add constraint
        [self addConstraintInSuperviewWithFirstAttribute:firstAttribute toItem:secondView toAttribute:toAttribute relatedBy:related multiplierBy:multiplier];
        [self resetAttributeWithView:secondView];
    }
    
    //clear attributes in array
    [self.constraintAttributes removeAllObjects];
    
    return self;
}

- (void)addConstraintInSuperviewWithFirstAttribute:(NSLayoutAttribute)firstAttribute toItem:(UIView *)view toAttribute:(NSLayoutAttribute)relatedAttribute relatedBy:(NSLayoutRelation)related multiplierBy:(CGFloat)multiplier {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                  attribute:firstAttribute
                                                                  relatedBy:related
                                                                     toItem:view
                                                                  attribute:relatedAttribute
                                                                 multiplier:multiplier
                                                                   constant:0];
    [self.view.superview addConstraint:constraint];//add constraint in superview
    self.lastConstraint = constraint;
    [self.tempRelatedConstraints addObject:constraint]; //add constraint object in the array
}

- (void)resetAttributeWithView:(UIView *)view {
    NSLayoutAttribute secondAttribute = [objc_getAssociatedObject(view, &kZXPAttributeKey) integerValue];
    if ( secondAttribute != NSLayoutAttributeNotAnAttribute ) {
        objc_setAssociatedObject(view, &kZXPAttributeKey, @(NSLayoutAttributeNotAnAttribute), OBJC_ASSOCIATION_ASSIGN);
    }
}

@end

#pragma mark - public category of view

@implementation UIView (ZXPAdditions)

- (id)zxp_top {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeTop), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_left {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeLeft), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_bottom {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeBottom), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_right {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeRight), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_leading {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeLeading), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_trailing {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeTrailing), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_width {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeWidth), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_height {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeHeight), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_centerX {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeCenterX), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_centerY {
    objc_setAssociatedObject(self, &kZXPAttributeKey, @(NSLayoutAttributeCenterY), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (void)zxp_addConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout {
    layout([[ZXPAutoLayoutMaker alloc] initWithView:self type:kZXPAutoLayoutMakerAdd]);
}

- (void)zxp_updateConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout {
    layout([[ZXPAutoLayoutMaker alloc] initWithView:self type:kZXPAutoLayoutMakerUpdate]);
}

- (void)zxp_printConstraintsForSelf {
    NSArray<__kindof NSLayoutConstraint *> *constrain = self.constraints;
    NSArray<__kindof NSLayoutConstraint *> *superConstrain = self.superview.constraints;
    NSMutableArray<__kindof NSLayoutConstraint *> *array = [NSMutableArray array];
    [array addObjectsFromArray:constrain];
    [array addObjectsFromArray:superConstrain];
    [array enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.firstItem == self) {
            NSLog(@"%@ -> %@ : %f",[self class],layoutAttributeString(obj.firstAttribute),obj.constant);
        }
    }];
}

NSString* layoutAttributeString(NSLayoutAttribute attribute) {
    NSString *attributeString;
#define enumToString(value) case value : attributeString = @#value; break;
    switch (attribute) {
            enumToString(NSLayoutAttributeLeft)
            enumToString(NSLayoutAttributeRight)
            enumToString(NSLayoutAttributeTop)
            enumToString(NSLayoutAttributeBottom)
            enumToString(NSLayoutAttributeLeading)
            enumToString(NSLayoutAttributeTrailing)
            enumToString(NSLayoutAttributeWidth)
            enumToString(NSLayoutAttributeHeight)
            enumToString(NSLayoutAttributeCenterX)
            enumToString(NSLayoutAttributeCenterY)
        default:
            enumToString(NSLayoutAttributeNotAnAttribute)
    }
#undef enumToString
    return attributeString;
}

@end

#pragma mark - category UITableView + ZXPCellAutoHeight

static NSString * const kZXPTableViewCellHeightDictionary = @"kZXPTableViewCellHeightDictionary_zxp";

NSString *p_zxp_heightDictionaryKey(NSIndexPath *indexPath);
void p_zxp_swizzleMethodOfSelf(Class aClass,SEL sel1,SEL sel2);

@implementation UITableView (ZXPCellAutoHeight)

+ (void)load {
    
    p_zxp_swizzleMethodOfSelf([self class], @selector(reloadData), @selector(p_zxp_swizzleReloadData));
    p_zxp_swizzleMethodOfSelf([self class],@selector(reloadRowsAtIndexPaths:withRowAnimation:),@selector(p_zxp_swizzleReloadRowsAtIndexPaths:withRowAnimation:));
    p_zxp_swizzleMethodOfSelf([self class],@selector(reloadSections:withRowAnimation:),@selector(p_zxp_swizzleReloadSections:withRowAnimation:));
    p_zxp_swizzleMethodOfSelf([self class],@selector(deleteSections:withRowAnimation:),@selector(p_zxp_swizzleDeleteSections:withRowAnimation:));
    p_zxp_swizzleMethodOfSelf([self class],@selector(deleteRowsAtIndexPaths:withRowAnimation:),@selector(p_zxp_swizzleDeleteRowsAtIndexPaths:withRowAnimation:));
}

#pragma mark - category UITableView + ZXPCellAutoHeight -> public apis

- (CGFloat)zxp_cellHeightWithindexPath:(NSIndexPath *)indexPath {
    return [self p_zxp_heightWithIndexPath:indexPath handle:^CGFloat(UITableViewCell *cell, NSIndexPath *indexPath) {
        NSMutableArray *maxYArray = [NSMutableArray array];
        [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.hidden) {
                [maxYArray addObject:@(CGRectGetMaxY(obj.frame))];
            }
        }];
        
        NSArray *compareMaxYArray = [maxYArray sortedArrayUsingSelector:@selector(compare:)];
        return [compareMaxYArray.lastObject floatValue];
    }];
}

- (CGFloat)zxp_cellHeightWithindexPath:(NSIndexPath *)indexPath space:(CGFloat)space {
    return [self zxp_cellHeightWithindexPath:indexPath] + space;
}

- (CGFloat)zxp_cellHeightWithindexPath:(NSIndexPath *)indexPath bottomView:(UIView *(^)(__kindof UITableViewCell *cell))block {
    return [self p_zxp_heightWithIndexPath:indexPath handle:^CGFloat(UITableViewCell *cell, NSIndexPath *indexPath) {
        if (!block) {
            return [self zxp_cellHeightWithindexPath:indexPath];
        }
        
        UIView *bottomView = block(cell);
        return CGRectGetMaxY(bottomView.frame);
    }];
}

- (CGFloat)zxp_cellHeightWithindexPath:(NSIndexPath *)indexPath bottomView:(UIView *(^)(__kindof UITableViewCell *cell))block space:(CGFloat)space {
    return [self zxp_cellHeightWithindexPath:indexPath bottomView:block] + space;
}

#pragma mark - private

- (CGFloat)p_zxp_heightWithIndexPath:(NSIndexPath *)indexPath handle:(CGFloat(^)(UITableViewCell *cell,NSIndexPath *indexPath))block {
    
    NSMutableDictionary *heightDictionary = [self p_zxp_heightDictionary];
    NSString *dictionaryKey = p_zxp_heightDictionaryKey(indexPath);
    CGFloat cacheHeight = [heightDictionary[dictionaryKey] floatValue];
    
    if (!cacheHeight) {
        UITableViewCell *cell = [self p_zxp_cellWithIndexPath:indexPath];
        
        CGFloat height = block(cell,indexPath);
        
        cacheHeight = !height ? CGFLOAT_MIN : height;
        [heightDictionary setObject:@(cacheHeight) forKey:dictionaryKey];
        
    }
    
    return cacheHeight;
}

- (NSMutableDictionary *)p_zxp_heightDictionary {
    NSMutableDictionary *heightDictionary = objc_getAssociatedObject(self, &kZXPTableViewCellHeightDictionary);
    if (!heightDictionary) {
        heightDictionary = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kZXPTableViewCellHeightDictionary, heightDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return heightDictionary;
}

- (UITableViewCell *)p_zxp_cellWithIndexPath:(NSIndexPath *)indexPath {
    id dataSourceObj = self.dataSource;
    
    NSAssert([dataSourceObj respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)], @"请实现 tableView:cellForRowAtIndexPath: 方法");
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window layoutIfNeeded];
    
    UITableViewCell *cell = [dataSourceObj tableView:self cellForRowAtIndexPath:indexPath];
    
    CGRect cellFrame = cell.frame;
    cellFrame.size.width = CGRectGetWidth(self.frame);
    cell.frame = cellFrame;
    
    [cell layoutIfNeeded];
    
    return cell;
}

#pragma mark swizzle method

- (void)p_zxp_swizzleReloadData {
    if ([self p_zxp_heightDictionary].count) {
        [[self p_zxp_heightDictionary] removeAllObjects];
    }
    [self p_zxp_swizzleReloadData];
}

- (void)p_zxp_swizzleReloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    
    if ([self p_zxp_heightDictionary].count) {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[self p_zxp_heightDictionary] removeObjectForKey:p_zxp_heightDictionaryKey(obj)];
        }];
    }
    
    [self p_zxp_swizzleReloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    
}

- (void)p_zxp_swizzleReloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    
    if ([self p_zxp_heightDictionary].count) {
        NSMutableArray *tempArray = [NSMutableArray array];
        
        [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            NSUInteger section = idx;
            [[[self p_zxp_heightDictionary] allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *sectionString = [obj componentsSeparatedByString:@"-"].firstObject;
                
                if (section == [sectionString longLongValue]) {
                    [tempArray addObject:obj];
                }
                
            }];
        }];
        
        [[self p_zxp_heightDictionary] removeObjectsForKeys:tempArray];
    }
    
    [self p_zxp_swizzleReloadSections:sections withRowAnimation:animation];
    
}

- (void)p_zxp_swizzleDeleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if ([self p_zxp_heightDictionary].count) {
        [[self p_zxp_heightDictionary] removeAllObjects];
    }
    [self p_zxp_swizzleDeleteSections:sections withRowAnimation:animation];
}

- (void)p_zxp_swizzleDeleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if ([self p_zxp_heightDictionary].count) {
        [[self p_zxp_heightDictionary] removeAllObjects];
    }
    [self p_zxp_swizzleDeleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

#pragma mark - private -> c

NSString *p_zxp_heightDictionaryKey(NSIndexPath *indexPath) {
    return [NSString stringWithFormat:@"%zi-%zi",indexPath.section,indexPath.row];
}

void p_zxp_swizzleMethodOfSelf(Class aClass,SEL sel1,SEL sel2) {
    method_exchangeImplementations(class_getInstanceMethod(aClass, sel1), class_getInstanceMethod(aClass, sel2));
}

@end






