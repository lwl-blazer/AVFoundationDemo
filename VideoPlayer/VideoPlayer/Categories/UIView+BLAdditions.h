//
//  UIView+BLAdditions.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (BLAdditions)

@property(nonatomic, assign) CGFloat frameX;
@property(nonatomic, assign) CGFloat frameY;
@property(nonatomic, assign) CGFloat frameWidth;
@property(nonatomic, assign) CGFloat frameHeight;

@property(nonatomic, assign) CGPoint frameOrigin;
@property(nonatomic, assign) CGSize frameSize;

@property (nonatomic, assign) CGFloat boundsX;
@property (nonatomic, assign) CGFloat boundsY;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

- (UIImage *)toImage;

- (UIImageView *)toImageView;

@end

NS_ASSUME_NONNULL_END
