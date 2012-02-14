//
//  CEGLKViewRendererAbstract.h
//  SoundWandGuiDev
//
//  Created by Hari Karam Singh on 01/01/2012.
//  Copyright (c) 2012 Amritvela / Club 15CC.  MIT License.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

/**
 Load and compile the shader with the specified name and returns its GL reference
 
 Code from: http://www.raywenderlich.com/3664/opengl-es-2-0-for-iphone-tutorial
 
 \param shaderName  The file name w/o extension
 \param shaderType  GL_VERTEX_SHADER or GL_FRAGMENT_SHADER
 */
GLuint MM_GLKCompileShader(NSString *shaderName,  GLenum shaderType);


/**
 Convenience method to compile a shader pair and create and link it to a program
 reporting any errors
 \param shaderHandles Array to place the GL shader handles so they can be deleted later
 */
GLuint MM_GLKCompileProgramForShaders(NSString *vshaderName, NSString *fshaderName, GLuint *shaderHandles);
