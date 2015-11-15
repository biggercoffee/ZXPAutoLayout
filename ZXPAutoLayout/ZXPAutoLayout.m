//
//  ZXPAutoLayout.m
//  layout
//
//  Created by coffee on 15/10/10.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import "ZXPAutoLayout.h"
#import <objc/runtime.h>

static NSString *ZXPAutoLayoutMakerAdd = @"ZXPAutoLayoutMakerAdd";
static NSString *ZXPAutoLayoutMakerUpdate = @"ZXPAutoLayoutMakerUpdate";

@interface ZXPAutoLayoutMaker ()

@property (nonatomic,strong) NSMutableArray *constraintAttributes;

/**
 *  @author coffee
 *
 *  temp save constraints for RelativeLayout (centerX,centerY,equal), do not save constraints for top,left,bottom,right,width,height
 */
@property (nonatomic,strong) NSMutableArray<NSLayoutConstraint *> *tempConstraints;

@property (nonatomic,strong) UIView *view;

@property (nonatomic,assign) id layoutType;

@end

@implementation ZXPAutoLayoutMaker

- (instancetype)initWithView:(UIView *)view type:(id)type {
    
    if (self = [super init]) {
        
        self.constraintAttributes = [NSMutableArray array];
        self.tempConstraints = [NSMutableArray array];
        
        self.view = view;
        self.layoutType = type;
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return self;
}

- (ZXPAutoLayoutMaker *)top {
    [self.tempConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeTop)];
    return self;
}

- (ZXPAutoLayoutMaker *)left {
    [self.tempConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeLeft)];
    return self;
}

- (ZXPAutoLayoutMaker *)bottom {
    [self.tempConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeBottom)];
    return self;
}

- (ZXPAutoLayoutMaker *)right {
    [self.tempConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeRight)];
    return self;
}

- (ZXPAutoLayoutMaker *)leading {
    [self.tempConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeLeading)];
    return self;
}

- (ZXPAutoLayoutMaker *)trailing {
    [self.tempConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeTrailing)];
    return self;
}

- (ZXPAutoLayoutMaker *)width {
    [self.tempConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeWidth)];
    return self;
}

- (ZXPAutoLayoutMaker *)height {
    [self.tempConstraints removeAllObjects];
    [self.constraintAttributes addObject:@(NSLayoutAttributeHeight)];
    return self;
}

- (ZXPAutoLayoutMaker *)with {
    [self.tempConstraints removeAllObjects];
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
        [self.tempConstraints addObject:constraintX];
        
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
        [self.tempConstraints addObject:constraintY];
        
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(id, CGFloat))equalToWithMultiplier {
    return ^(id value,CGFloat multiplier) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            return [self setupConstraint:[value floatValue] relatedBy:NSLayoutRelationEqual multiplierBy:multiplier];
        }
        else if ([value isKindOfClass:[UIView class]]) {
            return [self setupConstraintWithToItem:value relatedBy:NSLayoutRelationEqual multiplierBy:multiplier];
        }
        NSAssert(NO, @"%@ equalTo : Does not supper type",self.view);
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(id, CGFloat))greaterThanOrEqualWithMultiplier {
    return ^(id value,CGFloat multiplier){
        if ([value isKindOfClass:[NSNumber class]]) {
            return [self setupConstraint:[value floatValue] relatedBy:NSLayoutRelationGreaterThanOrEqual multiplierBy:multiplier];
        }
        else if ([value isKindOfClass:[UIView class]]) {
            return [self setupConstraintWithToItem:value relatedBy:NSLayoutRelationGreaterThanOrEqual multiplierBy:multiplier];
        }
        NSAssert(NO, @"%@ greaterThanOrEqual : Does not supper type",self.view);
        return self;
    };
}

- (ZXPAutoLayoutMaker *(^)(id, CGFloat))lessThanOrEqualWithMultiplier {
    return ^(id value,CGFloat multiplier) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            return [self setupConstraint:[value floatValue] relatedBy:NSLayoutRelationLessThanOrEqual multiplierBy:multiplier];
        }
        else if ([value isKindOfClass:[UIView class]]) {
            return [self setupConstraintWithToItem:value relatedBy:NSLayoutRelationLessThanOrEqual multiplierBy:multiplier];
        }
        NSAssert(NO, @"%@ lessThanOrEqual : Does not supper type",self.view);
        return self;
    };
}

#pragma mark - private

- (ZXPAutoLayoutMaker *)setupConstraint:(CGFloat)offset relatedBy:(NSLayoutRelation)related multiplierBy:(CGFloat)multiplier {
    
    if (!self.view.superview) {
        NSAssert(NO, @"%@ , no superview",self.view.class);
        return self;
    }
    
    if (self.tempConstraints.count) {
        
        for (NSLayoutConstraint *constraint in self.tempConstraints) { //update constant in tempConstraints
            constraint.constant = offset;
        }
        
        //clear
        [self.tempConstraints removeAllObjects];
        [self.constraintAttributes removeAllObjects];
        
        return self;
    }
    
    NSArray *array = [self.constraintAttributes valueForKeyPath:@"@distinctUnionOfObjects.self"];
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
    
    NSArray *array = [self.constraintAttributes valueForKeyPath:@"@distinctUnionOfObjects.self"];
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
        [self.tempConstraints addObject:constraint]; //add constraint object
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

#pragma mark - category

@implementation UIView (ZXPAdditions)

- (UIView *)zxp_top {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeTop), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (UIView *)zxp_left {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeLeading), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (UIView *)zxp_bottom {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeBottom), OBJC_ASSOCIATION_ASSIGN);
    return self;
}

- (UIView *)zxp_right {
    objc_setAssociatedObject(self, @selector(zxp_attribute), @(NSLayoutAttributeTrailing), OBJC_ASSOCIATION_ASSIGN);
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

@end
