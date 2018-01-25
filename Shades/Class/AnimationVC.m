//
//  AnimationVC.m
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

#import "AnimationVC.h"

@interface AnimationVC ()

@end

@implementation AnimationVC

+ (void)pushView:(UIViewController*)fromVC toVC:(UIViewController*)toVC toRight:(BOOL)bRight
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    if (bRight == YES)
        transition.subtype = kCATransitionFromRight;
    else
        transition.subtype = kCATransitionFromLeft;
    [fromVC.view.window.layer addAnimation:transition forKey:nil];
    
    [fromVC presentViewController:toVC animated:NO completion:nil];
}

+ (void)popView:(UIViewController*)vc toRight:(BOOL)bRight
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    if (bRight == YES)
        transition.subtype = kCATransitionFromRight;
    else
        transition.subtype = kCATransitionFromLeft;
    [vc.view.window.layer addAnimation:transition forKey:nil];
    
    [vc dismissViewControllerAnimated:NO completion:nil];
}

@end
