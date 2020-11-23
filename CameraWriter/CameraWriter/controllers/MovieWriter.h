//
//  MovieWriter.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MovieWriterDelegate <NSObject>
- (void)didWriteMovieAtURL:(NSURL *)outputURL;
@end

@interface MovieWriter : NSObject

- (id)initWithVideoSettings:(NSDictionary *)videoSettings
              audioSettings:(NSDictionary *)audioSettings
              dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)startWriting;
- (void)stopWriting;
@property (nonatomic) BOOL isWriting;

@property (weak, nonatomic) id<MovieWriterDelegate> delegate;

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
