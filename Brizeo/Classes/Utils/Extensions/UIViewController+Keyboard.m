//
//  UIViewController+Keyboard.m
//  KGBase
//
//  Copyright (c) 2015 Kogi Mobile. All rights reserved.
//

#import "UIViewController+Keyboard.h"
#import <objc/runtime.h>

@implementation UIViewController (Keyboard)

static char const * resizeViewWhenKeyboardAppearsKey = "resizeViewWhenKeyboardAppearsKey";
static char const * originalFrameKey = "originalFrameKey";

@dynamic resizeViewWhenKeyboardAppears;
@dynamic originalFrame;

-(void)setResizeViewWhenKeyboardAppears:(BOOL)resizeViewWhenKeyboardAppears {
    
    objc_setAssociatedObject(self, resizeViewWhenKeyboardAppearsKey, @(resizeViewWhenKeyboardAppears), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

-(BOOL)resizeViewWhenKeyboardAppears {
    
    return [objc_getAssociatedObject(self, resizeViewWhenKeyboardAppearsKey) boolValue];
}


-(void)setOriginalFrame:(CGRect)originalFrame {
    
    objc_setAssociatedObject(self, originalFrameKey, NSStringFromCGRect(originalFrame), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

-(CGRect)originalFrame {
    
    NSString * frameString = objc_getAssociatedObject(self, originalFrameKey);
    return CGRectFromString(frameString);
}


-(void)viewWillAppearKeyboard:(BOOL)animated {
    
    [self viewWillAppearKeyboard:animated];
    
    if (self.resizeViewWhenKeyboardAppears) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

-(void)viewWillDisappearKeyboard:(BOOL)animated {
    
    [self viewWillDisappearKeyboard:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


+(void)load {
    
    Method original, swizzled;
    
    original = class_getInstanceMethod(self, @selector(viewWillAppear:));
    swizzled = class_getInstanceMethod(self, @selector(viewWillAppearKeyboard:));
    method_exchangeImplementations(original, swizzled);
    
    original = class_getInstanceMethod(self, @selector(viewWillDisappear:));
    swizzled = class_getInstanceMethod(self, @selector(viewWillDisappearKeyboard:));
    method_exchangeImplementations(original, swizzled);
}



-(void)categoryKeyboardWillShow:(NSNotification *)note {
    
    if (CGRectIsEmpty(self.originalFrame)) {
        self.originalFrame = self.view.frame;
    }
    
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect keyboardFrameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    
    //fix when keyboard is hidden. Case running the app in simulator with software keyboard disabled was moving the view out of screen.
    if (!CGRectIsEmpty(keyboardFrameEnd) && !CGRectIsNull(keyboardFrameEnd)) {

        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
            
            self.view.frame = CGRectMake(0, self.originalFrame.origin.y, keyboardFrameEnd.size.width, keyboardFrameEnd.origin.y);
            
        } completion:nil];
    }

	[self keyboardWillAppear:note];
}

-(void)categoryKeyboardWillHide:(NSNotification *)note {
    
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
	CGRect keyboardFrameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    
    //fix when keyboard is hidden. Case running the app in simulator with software keyboard disabled was moving the view out of screen.
    if (!CGRectIsEmpty(self.originalFrame) && !CGRectIsNull(self.originalFrame)) {
    
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
            
            self.view.frame = self.originalFrame;
            
        } completion:nil];
    }

	[self keyboardWillHide:note];
}

#pragma mark - Utils

-(void)keyboardWillHide:(NSNotification *)notification {
    
    //override this method
}

-(void)keyboardWillAppear:(NSNotification *)notification {
    
    //override this method
}

@end
