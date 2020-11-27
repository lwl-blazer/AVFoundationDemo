//
//  UIAlertController+BLAdditions.m
//  FifteenSeconds
//
//  Created by luowailin on 2020/11/27.
//  Copyright © 2020 TapHarmonic, LLC. All rights reserved.
//

#import "UIAlertController+BLAdditions.h"

@implementation UIAlertController (BLAdditions)

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *control = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL];
    [control addAction:action];
    return control;
}

@end
