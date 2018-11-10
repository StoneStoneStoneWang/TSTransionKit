//
//  TSBaseViewController+TS_Transition.m
//  TSTSTransionKitDemo
//
//  Created by three stone 王 on 2018/11/7.
//  Copyright © 2018年 three stone 王. All rights reserved.
//

#import "TSBaseViewController+TS_Transition.h"
#import <objc/runtime.h>
// 利用Category 和Runtime实行方法hook hook方案有一个好处,就是可以避免代码入侵,做到更加广泛的通用性.通过swizzling我们可以将原method与自己加入的method相结合,即不需要在原有工程中加入代码,又能做到全局覆盖

void __ts_swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector){
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
#define TS_PanResponseW 100

@implementation TSBaseViewController (TS_Transition)

- (void)setInteractivePopTransition:(UIPercentDrivenInteractiveTransition *)interactivePopTransition {
    
    objc_setAssociatedObject(self, @"interactivePopTransition", interactivePopTransition, OBJC_ASSOCIATION_RETAIN);
}
- (UIPercentDrivenInteractiveTransition *)interactivePopTransition {
    
    return objc_getAssociatedObject(self, @"interactivePopTransition");
}

+ (void)load {
    
    [super load];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        __ts_swizzleMethod([self class], @selector(viewDidLoad), @selector(__ts__viewDidLoad));
    });
}
- (void)setPanResponseType:(TSPanResponseType)panResponseType {
    
    objc_setAssociatedObject(self, @"panResponseType", @(panResponseType), OBJC_ASSOCIATION_RETAIN);
}

- (TSPanResponseType)panResponseType {
    
    return [objc_getAssociatedObject(self, @"panResponseType") integerValue];
}
- (void)__ts__viewDidLoad {
    [self __ts__viewDidLoad];
    
    //由于方法已经被交换,这里调用的实际上是viewDidLoad方法
    
    if ([self isAddPan]) {
        
        [self addPanGesture];
    }
}
- (void)addPanGesture {
    
    if (self.navigationController && self != self.navigationController.viewControllers.firstObject)
    {
        UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePopRecognizer:)];
        
        [self.view addGestureRecognizer:popRecognizer];
        
        popRecognizer.delegate = self;
    }
}
- (BOOL)isAddPan {
    
    return true;
}

- (void)handlePopRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat progress = [recognizer translationInView:self.view].x / CGRectGetWidth(self.view.frame);
    
    progress = MIN(1.0, MAX(0.0, progress));
    
    //    NSLog(@"progress---%.2f",progress);
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc]init];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (progress > 0.25)
        {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else
        {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        self.interactivePopTransition = nil;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    switch (self.panResponseType) {
        case TSPanResponseTypeDefault:
        {
            BOOL result = [gestureRecognizer velocityInView:self.view].x > 0 && [gestureRecognizer locationInView:self.view].x < TS_PanResponseW;
            
            return result;
        }
        case TSPanResponseTypeFull:
        {
            return [gestureRecognizer velocityInView:self.view].x > 0;
        }
        case TSPanResponseTypeCustom:
        {
            BOOL result = [gestureRecognizer velocityInView:self.view].x > 0 && [gestureRecognizer locationInView:self.view].x < self.panResponseW;
            
            return result;
        }
        default:
        {
            BOOL result = [gestureRecognizer velocityInView:self.view].x > 0 && [gestureRecognizer locationInView:self.view].x < TS_PanResponseW;
            
            return result;
        }
    }
}

- (CGFloat)panResponseW {
    
    return TS_PanResponseW;
}
- (void)popEnded {
    
    NSLog(@"popEnded");
}
- (void)pushEnded {
    
    NSLog(@"pushEnded");
}

@end