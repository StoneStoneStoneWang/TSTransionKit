//
//  TSNaviTransitionViewController.h
//  TSTSTransionKitDemo
//
//  Created by three stone 王 on 2018/11/7.
//  Copyright © 2018年 three stone 王. All rights reserved.
//

#import "TSNavigationController.h"
#import "TSBaseTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSNaviBottomUpViewController : TSNavigationController <UIViewControllerTransitioningDelegate>

// 消失的时候可能需要用到
- (void)setDimissBlock:(DismissCompletion )dismiss;

@property (nonatomic ,assign ) BOOL opacityCanResponse;

@end

NS_ASSUME_NONNULL_END
