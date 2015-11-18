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

static NSString *ZXPAutoLayoutMakerAdd = @"ZXPAutoLayoutMakerAdd";
static NSString *ZXPAutoLayoutMakerUpdate = @"ZXPAutoLayoutMakerUpdate";

@interface ZXPAutoLayoutMaker ()

@property (nonatomic,strong) NSMutableArray *constraintAttributes;

/**
 *  @author coffee
 *
 *  temp save constraints for RelativeLayout (centerX,centerY,equal), do not save constraints for top,left,bottom,right,width,height
 */
@property (nonatomic,strong) NSMutableArray<NSLayoutConstraint *> *tempRelatedConstraints;

@property (nonatomic,strong) UIView *view;

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

- (ZXPAutoLayoutMaker *(^)(id, CGFloat))equalToWithMultiplier {
    return ^(id value,CGFloat multiplier) {
        return [self constraint:value relatedBy:NSLayoutRelationEqual multiplier:multiplier];
    };
}

- (ZXPAutoLayoutMaker *(^)(id, CGFloat))greaterThanOrEqualWithMultiplier {
    return ^(id value,CGFloat multiplier){
        return [self constraint:value relatedBy:NSLayoutRelationGreaterThanOrEqual multiplier:multiplier];
    };
}

- (ZXPAutoLayoutMaker *(^)(id, CGFloat))lessThanOrEqualWithMultiplier {
    return ^(id value,CGFloat multiplier) {
        return [self constraint:value relatedBy:NSLayoutRelationLessThanOrEqual multiplier:multiplier];
    };
}

#pragma mark - private methods

- (id)constraint:(id)value relatedBy:(NSLayoutRelation)relateBy multiplier:(CGFloat)multiplier {
    if ([value isKindOfClass:[NSNumber class]]) {
        return [self setupConstraint:[value floatValue] relatedBy:relateBy multiplierBy:multiplier];
    }
    else if ([value isKindOfClass:[UIView class]]) {
        return [self setupConstraintWithToItem:value relatedBy:relateBy multiplierBy:multiplier];
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
        
        NSLayoutAttribute layoutAttribute = [attribute integerValue];
        
        if ( self.layoutType == ZXPAutoLayoutMakerAdd ) {
            
            if (layoutAttribute == NSLayoutAttributeWidth || layoutAttribute == NSLayoutAttributeHeight) {
                
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                      attribute:layoutAttribute
                                                                      relatedBy:related
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:multiplier
                                                                       constant:offset]];
                
            }
            else {
                
                [self.view.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                                attribute:layoutAttribute
                                                                                relatedBy:related
                                                                                   toItem:self.view.superview
                                                                                attribute:layoutAttribute
                                                                               multiplier:multiplier
                                                                                 constant:offset]];
                
            }
            
        }
        else { //update
            [self updateConstraintWithView:self.view attribute:layoutAttribute value:offset];
        }
        
    } //end for
    
    //clear attributes in array
    [self.constraintAttributes removeAllObjects];
    
    return self;
}

- (ZXPAutoLayoutMaker *)setupConstraintWithToItem:(UIView *)view relatedBy:(NSLayoutRelation)related multiplierBy:(CGFloat)multiplier {
    
    if (!self.view.superview) {
        NSAssert(NO, @"%@ , no superview",self.view.class);
        return self;
    }
    
    NSArray *array = [self.constraintAttributes distinctUnionOfObjects];
    if (self.layoutType == ZXPAutoLayoutMakerAdd) {
        
        for (id attribute in array) {
            
            NSLayoutAttribute layoutAttribute = [attribute integerValue];
            
            NSLayoutAttribute relatedAttribute = view.zxp_attribute != NSLayoutAttributeNotAnAttribute ? view.zxp_attribute : layoutAttribute;
            
            //add constraint
            [self setupConstraintWithAttribute:layoutAttribute toItem:view toAttribute:relatedAttribute relatedBy:related multiplierBy:multiplier];
            
        }
        
    }
    else { //update
        
        [self.view.superview.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            for (id attribute in array) {
                
                NSLayoutAttribute layoutAttribute = [attribute integerValue];
                NSLayoutAttribute relatedAttribute = view.zxp_attribute != NSLayoutAttributeNotAnAttribute ? view.zxp_attribute : layoutAttribute;
                
                if (obj.firstItem == self.view && obj.firstAttribute == layoutAttribute) {
                    
                    [self.view.superview removeConstraint:obj]; //remove
                    //add constraint
                    [self setupConstraintWithAttribute:layoutAttribute toItem:view toAttribute:relatedAttribute relatedBy:related multiplierBy:multiplier];
                    
                }
                
            }
            
        }];
    }
    
    //clear attributes in array
    [self.constraintAttributes removeAllObjects];
    
    return self;
}

- (void)setupConstraintWithAttribute:(NSLayoutAttribute)layoutAttribute toItem:(UIView *)view toAttribute:(NSLayoutAttribute)relatedAttribute relatedBy:(NSLayoutRelation)related multiplierBy:(CGFloat)multiplier {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                  attribute:layoutAttribute
                                                                  relatedBy:related
                                                                     toItem:view
                                                                  attribute:relatedAttribute
                                                                 multiplier:multiplier
                                                                   constant:0];
    
    
    [self.view.superview addConstraint:constraint];//add constraint in superview
    
    
    if ( view.zxp_attribute != NSLayoutAttributeNotAnAttribute ) {
        objc_setAssociatedObject(view, @selector(zxp_attribute), @(NSLayoutAttributeNotAnAttribute), OBJC_ASSOCIATION_ASSIGN);
        [self.tempRelatedConstraints addObject:constraint]; //add constraint object
    }
}

- (void)updateConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute value:(float) value {
    
    NSArray<__kindof NSLayoutConstraint *> *constraints = attribute == NSLayoutAttributeWidth || attribute == NSLayoutAttributeHeight ? view.constraints : view.superview.constraints;
    [constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.firstItem == view && obj.firstAttribute == attribute) {
            obj.constant = value;
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
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeTop), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_left {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeLeft), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_bottom {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeBottom), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_right {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeRight), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_leading {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeLeading), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_trailing {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeTrailing), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_width {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeWidth), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_height {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeHeight), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_centerX {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeCenterX), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (id)zxp_centerY {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeCenterY), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (NSLayoutAttribute)zxp_attribute {
    return [objc_getAssociatedObject(self, @selector(zxp_attribute)) integerValue];
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
