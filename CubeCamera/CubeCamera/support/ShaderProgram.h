//
//  ShaderProgram.h
//  CubeCamera
//
//  Created by luowailin on 2020/11/16.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ShaderProgram : NSObject

- (instancetype)initWithShaderName:(NSString *)name;
- (void)addVertextAttribute:(GLKVertexAttrib)attribute named:(NSString *)name;
- (GLuint)uniformIndex:(NSString *)uniform;
- (BOOL)linkProgram;
- (void)useProgram;

@end

NS_ASSUME_NONNULL_END
