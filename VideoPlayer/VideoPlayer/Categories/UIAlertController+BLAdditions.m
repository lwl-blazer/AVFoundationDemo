//
//  UIAlertController+BLAdditions.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import "UIAlertController+BLAdditions.h"

@implementation UIAlertController (BLAdditions)

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:action];
    return alert;
}

@end
