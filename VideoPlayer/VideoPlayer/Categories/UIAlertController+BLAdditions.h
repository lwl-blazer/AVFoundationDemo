//
//  UIAlertController+BLAdditions.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (BLAdditions)

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
