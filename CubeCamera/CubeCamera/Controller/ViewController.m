//
//  ViewController.m
//  CubeCamera
//
//  Created by luowailin on 2020/11/16.
//

#import "ViewController.h"
#import "CameraController.h"
#import "ShaderProgram.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

enum {
    UNIFORM_MVP_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

GLint uniforms[NUM_UNIFORMS];

@interface ViewController ()<TextureDelegate>

@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic, strong) CameraController *cameraController;
@property(nonatomic, strong) ShaderProgram *shaderProgram;

@end

@implementation ViewController{
    GLKMatrix4 _mvpMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create OpenGL ES 2.0 context");
    }
    
    GLKView *view = (GLKView *)self.view;
    
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setUpGL];
    
    NSError *error;
    self.cameraController = [[CameraController alloc] initWithContext:self.context];
    self.cameraController.textureDelegate = self;
    if ([self.cameraController setupSession:&error]) {
        [self.cameraController switchCameras];
        [self.cameraController startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (void)setUpGL{
    GLfloat cubeVertices[] = {
    //  Position                 Normal                  Texture
     // x,    y,     z           x,    y,    z           s,    t
        0.5f, -0.5f, -0.5f,      1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,      1.0f, 0.0f, 0.0f,       1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,      1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,      1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,      1.0f, 0.0f, 0.0f,       1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,      1.0f, 0.0f, 0.0f,       0.0f, 0.0f,

        0.5f, 0.5f, -0.5f,       0.0f, 1.0f, 0.0f,       1.0f, 0.0f,
       -0.5f, 0.5f, -0.5f,       0.0f, 1.0f, 0.0f,       0.0f, 0.0f,
        0.5f, 0.5f,  0.5f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,
        0.5f, 0.5f,  0.5f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,
       -0.5f, 0.5f, -0.5f,       0.0f, 1.0f, 0.0f,       0.0f, 0.0f,
       -0.5f, 0.5f,  0.5f,       0.0f, 1.0f, 0.0f,       0.0f, 1.0f,

       -0.5f,  0.5f, -0.5f,     -1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
       -0.5f, -0.5f, -0.5f,     -1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
       -0.5f,  0.5f,  0.5f,     -1.0f, 0.0f, 0.0f,       0.0f, 0.0f,
       -0.5f,  0.5f,  0.5f,     -1.0f, 0.0f, 0.0f,       0.0f, 0.0f,
       -0.5f, -0.5f, -0.5f,     -1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
       -0.5f, -0.5f,  0.5f,     -1.0f, 0.0f, 0.0f,       1.0f, 0.0f,

       -0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,      1.0f, 0.0f,
        0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,      0.0f, 0.0f,
       -0.5f, -0.5f,  0.5f,      0.0f, -1.0f, 0.0f,      1.0f, 1.0f,
       -0.5f, -0.5f,  0.5f,      0.0f, -1.0f, 0.0f,      1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,      0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,      0.0f, -1.0f, 0.0f,      0.0f, 1.0f,

        0.5f,  0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       0.0f, 0.0f,
       -0.5f,  0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       0.0f, 1.0f,
        0.5f, -0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       1.0f, 0.0f,
        0.5f, -0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       1.0f, 0.0f,
       -0.5f,  0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       0.0f, 1.0f,
       -0.5f, -0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       1.0f, 1.0f,

        0.5f, -0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      0.0f, 1.0f,
       -0.5f, -0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      0.0f, 0.0f,
        0.5f,  0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      0.0f, 0.0f,
       -0.5f, -0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      1.0f, 1.0f,
       -0.5f,  0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      1.0f, 0.0f
    };
    
    [EAGLContext setCurrentContext:self.context];
    
    self.shaderProgram = [[ShaderProgram alloc] initWithShaderName:@"Shader"];
    [self.shaderProgram addVertextAttribute:GLKVertexAttribPosition named:@"position"];
    [self.shaderProgram addVertextAttribute:GLKVertexAttribTexCoord0 named:@"videoTextureCoordinate"];
    [self.shaderProgram linkProgram];
    
    
    uniforms[UNIFORM_MVP_MATRIX] = [self.shaderProgram uniformIndex:@"mvpMatrix"];
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          8 * sizeof(GLfloat),
                          BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          8 * sizeof(GLfloat),
                          BUFFER_OFFSET(3 * sizeof(GLfloat)));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          3,
                          GL_FLOAT,
                          GL_TRUE,
                          8 * sizeof(GLfloat),
                          BUFFER_OFFSET(6 * sizeof(GLfloat)));
}

- (void)tearDownGL{
    [EAGLContext setCurrentContext:self.context];
    glDeleteBuffers(1, &_vertexBuffer);
}

#pragma mark - TextureDelegate
- (void)textureCreatedWithTarget:(GLenum)target name:(GLuint)name{
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(target, name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

#pragma mark - GLKViewController method overrides
- (void)update{
    CGRect bounds = self.view.bounds;
    
    GLfloat aspect = fabs(CGRectGetWidth(bounds) / CGRectGetHeight(bounds));
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f),
                                                            aspect,
                                                            0.1f,
                                                            100.0f);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,
                                                           0.0f,
                                                           -3.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.f, 1.f, 1.f);
    
    _mvpMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 0.75;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    
    [self.shaderProgram useProgram];
    
    glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, 0, _mvpMatrix.m);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    glDrawArrays(GL_TRIANGLES, 0, 36);
}



@end
