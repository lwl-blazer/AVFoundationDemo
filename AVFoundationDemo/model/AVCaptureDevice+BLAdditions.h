//
//  AVCaptureDevice+BLAdditions.h
//  AVFoundationDemo
//
//  Created by blazer on 2019/2/19.
//  Copyright © 2019 blazer. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCaptureDevice (BLAdditions)

- (BOOL)supportsHighFrameRateCapture;  //设备是否支持高帧率捕捉

- (BOOL)enableHighFrameRateCapture:(NSError **)error;    //实现高帧率捕捉功能

@end

NS_ASSUME_NONNULL_END
/*
 
 高帧率捕捉
 
 AVFrameRateRange 对象数组   包括 最小帧率   最大帧率  和时长信息
 
 使用高帧率捕捉的一个基本秘决就是找到设备的最高质量格式 ， 找到它相关的帧时长， 之后手动设置捕捉设备的格式和帧时长
 */
