//
//  PreviewView.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "PreviewView.h"
#import "ContextManager.h"
#import "BLFunctions.h"
#import "BLNotifications.h"

@interface PreviewView ()

@property(nonatomic) CGRect drawableBounds;

@end


@implementation PreviewView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    self = [super initWithFrame:frame context:context];
    if (self) {
        self.enableSetNeedsDisplay = NO;
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
        
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.frame = frame;
        
        [self bindDrawable];
        
        _drawableBounds = self.bounds;
        _drawableBounds.size.width = self.drawableWidth;
        _drawableBounds.size.height = self.drawableHeight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(filterChanged:)
                                                     name:BLFilterSelectionChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)filterChanged:(NSNotification *)notification{
    self.filter = notification.object;
}

- (void)setImage:(CIImage *)image{
    [self bindDrawable];
    
    [self.filter setValue:image forKey:kCIInputImageKey];
    CIImage *filteredImage = self.filter.outputImage;
    if (filteredImage) {
        CGRect cropRect = BLCenterCropImageRect(image.extent, self.drawableBounds);
        
        [self.coreImageContext drawImage:filteredImage
            inRect:self.drawableBounds
                                fromRect:cropRect];
    }
    
    [self display];
    //渲染完清空
    [self.filter setValue:nil forKey:kCIInputImageKey];
}

@end
