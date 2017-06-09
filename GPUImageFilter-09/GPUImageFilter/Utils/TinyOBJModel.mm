//
//  TinyOBJModel.cpp
//  GLKit
//
//  Created by qinmin on 2017/1/14.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#include "TinyOBJModel.h"

int TinyOBJModel::LoadObj(const char *objPath)
{
    std::string err;
    bool ret = tinyobj::LoadObj(&attrib, &shapes, &materials, &err, objPath);
    
    if (!err.empty()) {
        std::cerr << err << std::endl;
    }
    if (!ret) {
        return -1;
    }
    
    std::vector<tinyobj::index_t> indexVector;
    std::vector<long> elementVector;
    
    // Loop over shapes
    for (size_t s = 0; s < shapes.size(); s++) {
        // Loop over faces(polygon)
        size_t index_offset = 0;
        for (size_t f = 0; f < shapes[s].mesh.num_face_vertices.size(); f++) {
            int fv = shapes[s].mesh.num_face_vertices[f];
            
            // Loop over vertices in the face.
            for (size_t v = 0; v < fv; v++) {
                // access to vertex
                tinyobj::index_t idx = shapes[s].mesh.indices[index_offset + v];
                
                long currentIdx = -1;
                for (size_t i = 0; i < indexVector.size(); i++) {
                    tinyobj::index_t tmpIdx = indexVector[i];
                    if (idx.normal_index == tmpIdx.normal_index && idx.texcoord_index == tmpIdx.texcoord_index && idx.vertex_index == tmpIdx.vertex_index) {
                        currentIdx = i;
                    }
                }
                if (currentIdx == -1) {
                    currentIdx = indexVector.size();
                    indexVector.push_back(idx);
                }
                elementVector.push_back(currentIdx);
            }
            index_offset += fv;
            
            // per-face material
            shapes[s].mesh.material_ids[f];
        }
    }
    
    long indexCount = (int)elementVector.size();
    unsigned int *indexes = new unsigned int[indexCount];
    for (long i = 0; i< indexCount; i++) {
        indexes[i] = (unsigned int)elementVector[i];
    }
    
    long vertexCount = (int)indexVector.size();
    VertexData *vertexes = new VertexData[vertexCount];
    for (int i = 0; i< vertexCount; ++i) {
        tinyobj::index_t idx = indexVector[i];
        float vx = attrib.vertices[3*idx.vertex_index+0];
        float vy = attrib.vertices[3*idx.vertex_index+1];
        float vz = attrib.vertices[3*idx.vertex_index+2];
        float nx = 0.0;
        float ny = 0.0;
        float nz = 0.0;
        float tx = 0.0;
        float ty = 0.0;
        if (attrib.normals.size() > 0) {
            nx = attrib.normals[3*idx.normal_index+0];
            ny = attrib.normals[3*idx.normal_index+1];
            nz = attrib.normals[3*idx.normal_index+2];
        }
        if (attrib.texcoords.size() > 0) {
            tx = attrib.texcoords[2*idx.texcoord_index+0];
            ty = attrib.texcoords[2*idx.texcoord_index+1];
        }
        vertexes[i] = (VertexData){{vx, vy, vz}, {tx, ty}, {nx, ny, nz}};
    }
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(VertextData), vertexes, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount * sizeof(unsigned int), indexes, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    _indexCount = (int)indexCount;
    
    delete [] indexes;
    delete [] vertexes;
    
    return 1;
}

GLuint TinyOBJModel::getIndexBuffer()
{
    return _indexBuffer;
}

GLuint TinyOBJModel::getVertexBuffer()
{
    return _vertexBuffer;
}

int TinyOBJModel::getIndexCount()
{
    return _indexCount;
}

