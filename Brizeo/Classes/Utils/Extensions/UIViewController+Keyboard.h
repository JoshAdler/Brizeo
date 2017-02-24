//
//  UIViewController+Keyboard.h
//  KGBase
//
//  Copyright (c) 2015 Kogi Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Keyboard)

@property (nonatomic, assign) BOOL resizeViewWhenKeyboardAppears;
@property (nonatomic, assign) CGRect originalFrame;

-(void)keyboardWillHide:(NSNotification *)notification;

-(void)keyboardWillAppear:(NSNotification *)notification;;

@end
