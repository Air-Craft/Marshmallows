//
//  CEGLKViewRendererAbstract.m
//  SoundWandGuiDev
//
//  Created by Hari Karam Singh on 01/01/2012.
//  Copyright (c) 2012 Amritvela / Club 15CC.  MIT License.
//

#import "MMGLK.h"


/**********************************************************************/


GLuint MM_GLKCompileShader(NSString *shaderName,  GLenum shaderType)
{
    // Load the shader file contents
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName 
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath 
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // Source and compile the shader code
    GLuint shaderHandle = glCreateShader(shaderType);    
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    glCompileShader(shaderHandle);
    
    // Check error messages...
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }

    // Return the GL handle
    return shaderHandle;
}

/**********************************************************************/


GLuint MM_GLKCompileProgramForShaders(NSString *vshaderName, NSString *fshaderName, GLuint *shaderHandles)
{
    // Compile the shaders
    GLuint vertexShader = MM_GLKCompileShader(vshaderName,GL_VERTEX_SHADER);
    GLuint fragmentShader = MM_GLKCompileShader(fshaderName, GL_FRAGMENT_SHADER);
    
    // Create the program and link the shaders
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // Report any errors
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // Return the handles
    shaderHandles[0] = vertexShader;
    shaderHandles[1] = fragmentShader;
    return programHandle;
}


