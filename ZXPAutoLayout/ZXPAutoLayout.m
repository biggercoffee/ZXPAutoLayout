//
//  ZXPAutoLayout.m
//  layout
//
//  Created by coffee on 15/10/10.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import "ZXPAutoLayout.h"
#import <objc/runtime.h>

@interface NSArray (ZXPPrivateOfAutoLayout)

- (NSArray *)distinctUnionOfObjects;

@end

static NSString * const ZXPAutoLayoutMakerAdd = @"ZXPAutoLayoutMakerAdd";
static NSString * const ZXPAutoLayoutMakerUpdate = @"ZXPAutoLayoutMakerUpdate";
static NSString * const ZXPAttributeKey = @"ZXPAttributeKey~!";

@interface ZXPAutoLayoutMaker ()

@property (nonatomic,strong) NSMutableArray *constraintAttributes;

/**
 *  @author coffee
 *
 *  temp save constraints for RelativeLayout (centerX,centerY,equal), do not save constraints for top,left,bottom,right,width,height
 */
@property (nonatomic,strong) NSMutableArray<NSLayoutConstraint *> *tempRelatedConstraints;

@property (nonatomic,strong) UIView *view;
@property (strong,nonatomic) NSLayoutConstraint *lastConstraint;
@property (nonatomic,assign) id layoutType;

@end

@implementation ZXPAutoLayoutMaker

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

- (ZXPAutoLayoutMaker *)top {
    [self.tempRelatedConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeTop)];
    return self;
}

- (ZXPAutoLayoutMaker *)left {
    [self.tempRelatedConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeLeft)];
    return self;
}

- (ZXPAutoLayoutMaker *)bottom {
    [self.tempRelatedConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeBottom)];
    return self;
}

- (ZXPAutoLayoutMaker *)right {
    [self.tempRelatedConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeRight)];
    return self;
}

- (ZXPAutoLayoutMaker *)leading {
    [self.tempRelatedConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeLeading)];
    return self;
}

- (ZXPAutoLayoutMaker *)trailing {
    [self.tempRelatedConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeTrailing)];
    return self;
}

- (ZXPAutoLayoutMaker *)width {
    [self.tempRelatedConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeWidth)];
    return self;
}

- (ZXPAutoLayoutMaker *)height {
    [self.tempRelatedConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeHeight)];
    return self;
}

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

- (ZXPAutoLayoutMaker *(^)(CGSize))size {
    return ^(CGSize size) {
        self.width.offset(size.width);
        self.height.offset(size.height);
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(CGPoint))origin {
    return ^(CGPoint origin) {
        self.top.offset(origin.y);
        self.left.offset(origin.x);
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(CGRect))frame {
    return ^(CGRect frame) {
        return self.top.offset(CGRectGetMinY(frame)).left.offset(CGRectGetMinX(frame)).width.offset(CGRectGetWidth(frame)).height.offset(CGRectGetHeight(frame));
    };
}

- (ZXPAutoLayoutMaker *(^)(UIEdgeInsets))insets {
    return ^(UIEdgeInsets insets) {
        return self.top.offset(insets.top).left.offset(insets.left).bottom.offset(insets.bottom).right.offset(insets.right);
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *))center {
    return ^(UIView *view) {
        self.centerX(view);
        self.centerY(view);
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *))centerX {
    return ^(UIView *view) {
        
        NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:self.view
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:view
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:0];
        [self.view.superview addConstraint:constraintX];
        [self.tempRelatedConstraints addObject:constraintX];
        
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(UIView *))centerY {
    return ^(UIView *view) {
        
        NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:self.view
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:view
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0];
        [self.view.superview addConstraint:constraintY];
        [self.tempRelatedConstraints addObject:constraintY];
        
        return self;
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

/**
 *  @author coffee
 *
 *  @brief  添加约束如果存在则会先删除在添加
 *
 *  @param value      view or nsnumber
 *  @param relateBy   NSLayoutRelation 属性
 *  @param multiplier 比例
 *
 *  @return self
 */
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

/**
 *  @author coffee
 *
 *  @brief  设置约束值,如果tempRelatedConstraints不为空就更新tempRelatedConstraints里的约束(constant),否则就添加约束或者更新约束
 *
 *  @param offset     constant
 *  @param related    等于,小于等于,大于等于
 *  @param multiplier 比例
 *
 *  @return self
 */
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
        
        if ( self.layoutType == ZXPAutoLayoutMakerAdd ) {
            
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
            [self updateConstraintWithFirstView:self.view firstAttribute:firstAttribute constant:offset];
        }
        
    } //end for
    
    //clear attributes in array
    [self.constraintAttributes removeAllObjects];
    
    return self;
}

/**
 *  @author coffee
 *
 *  @brief  根据数组(constraintAttributes变量)里保存的约束属性进行约束添加,如果约束存在则会先移除在进行添加
            添加完约束之后会清空此数组(constraintAttributes变量) 并 重置第二个view的 NSLayoutAttribute 属性为 NSLayoutAttributeNotAnAttribute
 *
 *  @param secondView 第二个view
 *  @param related    等于,小于等于,大于等于
 *  @param multiplier 比例
 *
 *  @return 当前对象
 */
- (ZXPAutoLayoutMaker *)reAddConstraintOfAttributesWithToItem:(UIView *)secondView relatedBy:(NSLayoutRelation)related multiplierBy:(CGFloat)multiplier {
    
    if (!self.view.superview) {
        NSAssert(NO, @"%@ , not superview",self.view.class);
        return self;
    }
    
    NSArray *distinctUnionAttributes = [self.constraintAttributes distinctUnionOfObjects];
    NSLayoutAttribute secondAttribute = [objc_getAssociatedObject(secondView, &ZXPAttributeKey) integerValue];
    
    if (self.layoutType == ZXPAutoLayoutMakerUpdate) { //如果是更新约束,就先删掉view对应的相对约束
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
    NSLayoutAttribute secondAttribute = [objc_getAssociatedObject(view, &ZXPAttributeKey) integerValue];
    if ( secondAttribute != NSLayoutAttributeNotAnAttribute ) {
        objc_setAssociatedObject(view, &ZXPAttributeKey, @(NSLayoutAttributeNotAnAttribute), OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void)updateConstraintWithFirstView:(UIView *)view firstAttribute:(NSLayoutAttribute)attribute constant:(CGFloat)constant {
    
    NSArray<__kindof NSLayoutConstraint *> *constraints = attribute == NSLayoutAttributeWidth || attribute == NSLayoutAttributeHeight ? view.constraints : view.superview.constraints;
    [constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.firstItem == view && obj.firstAttribute == attribute) {
            obj.constant = constant;
            *stop = YES;
        }
    }];
    
}

@end

#pragma mark - private category of array

@implementation NSArray (ZXPPrivateOfAutoLayout)

- (NSArray *)distinctUnionOfObjects {
    return [self valueForKeyPath:@"@distinctUnionOfObjects.self"];
}

@end

#pragma mark - public category of view

@implementation UIView (ZXPAdditions)

- (id)zxp_top {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeTop), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_left {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeLeft), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_bottom {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeBottom), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_right {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeRight), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_leading {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeLeading), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_trailing {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeTrailing), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_width {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeWidth), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_height {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeHeight), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_centerX {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeCenterX), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_centerY {
    objc_setAssociatedObject(self, &ZXPAttributeKey, @(NSLayoutAttributeCenterY), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (void)zxp_addConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout {
    layout([[ZXPAutoLayoutMaker alloc] initWithView:self type:ZXPAutoLayoutMakerAdd]);
}

- (void)zxp_updateConstraints:(void(^)(ZXPAutoLayoutMaker *layout))layout {
    layout([[ZXPAutoLayoutMaker alloc] initWithView:self type:ZXPAutoLayoutMakerUpdate]);
}

- (void)zxp_printConstraintsForSelf {
    NSArray<__kindof NSLayoutConstraint *> *constrain = self.constraints;
    NSArray<__kindof NSLayoutConstraint *> *superConstrain = self.superview.constraints;
    NSMutableArray<__kindof NSLayoutConstraint *> *array = [NSMutableArray array];
    [array addObjectsFromArray:constrain];
    [array addObjectsFromArray:superConstrain];
    [array enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.firstItem == self) {
            NSLog(@"%@:%f",layoutAttributeString(obj.firstAttribute),obj.constant);
        }
    }];
}

NSString* layoutAttributeString(NSLayoutAttribute attribute) {
    switch (attribute) {
        case NSLayoutAttributeLeft:
            return @"left";
        case NSLayoutAttributeRight:
            return @"right";
        case NSLayoutAttributeTop:
            return @"top";
        case NSLayoutAttributeBottom:
            return @"bottom";
        case NSLayoutAttributeLeading:
            return @"leading";
        case NSLayoutAttributeTrailing:
            return @"trailing";
        case NSLayoutAttributeWidth:
            return @"width";
        case NSLayoutAttributeHeight:
            return @"height";
        case NSLayoutAttributeCenterX:
            return @"centerX";
        case NSLayoutAttributeCenterY:
            return @"centerY";
        default:
            return @"not attribute";
    }
}

@end
