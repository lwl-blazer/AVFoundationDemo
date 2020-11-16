attribute vec4 position;
attribute vec2 videoTextureCoordinate;

uniform mat4 mvpMatrix;

varying vec2 textureCoordinate;

void main()
{
    textureCoordinate = videoTextureCoordinate;
    gl_Position = mvpMatrix * position;
}
