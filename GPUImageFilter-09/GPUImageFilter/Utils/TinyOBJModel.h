//
//  TinyOBJModel.hpp
//  GLKit
//
//  Created by qinmin on 2017/1/14.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#ifndef TinyOBJModel_hpp
#define TinyOBJModel_hpp

#include <OpenGLES/ES2/gl.h>
#include <iostream>
#include "tiny_obj_loader.h"

typedef struct VertexData {
    float position[3];
    float texcoord[2];
    float normal[3];
} VertextData;

class TinyOBJModel {
    
private:
    GLuint _indexBuffer;
    GLuint _vertexBuffer;
    int   _indexCount;
    
    // tinyobj
    tinyobj::attrib_t attrib;
    std::vector<tinyobj::shape_t> shapes;
    std::vector<tinyobj::material_t> materials;

public:    
    int LoadObj(const char *objPath);
    GLuint getVertexBuffer();
    GLuint getIndexBuffer();
    int getIndexCount();
};

#endif /* TinyOBJModel_hpp */
