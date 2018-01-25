//
//  AnimationVC.h
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimationVC : NSObject

+ (void)pushView:(UIViewController*)fromVC toVC:(UIViewController*)toVC toRight:(BOOL)bRight;

+ (void)popView:(UIViewController*)vc toRight:(BOOL)bRight;

@end
