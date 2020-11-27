//
//  UIAlertController+BLAdditions.h
//  FifteenSeconds
//
//  Created by luowailin on 2020/11/27.
//  Copyright © 2020 TapHarmonic, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (BLAdditions)

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
