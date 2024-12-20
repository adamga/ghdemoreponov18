#include "cube.h"
#include <d3d12.h>
#include <DirectXMath.h>

using namespace DirectX;

struct Vertex {
    XMFLOAT3 position;
    XMFLOAT4 color;
};

Cube::Cube(ID3D12Device* device) : vertexBuffer(nullptr), indexBuffer(nullptr), indexCount(0), rotationAngle(0.0f) {
    createBuffers(device);
}

Cube::~Cube() {
    if (vertexBuffer) vertexBuffer->Release();
    if (indexBuffer) indexBuffer->Release();
}

void Cube::createBuffers(ID3D12Device* device) {
    // Define the vertices and indices for a cube
    Vertex vertices[] = {
        { XMFLOAT3(-1.0f, -1.0f, -1.0f), XMFLOAT4(1.0f, 0.0f, 0.0f, 1.0f) },
        { XMFLOAT3(1.0f, -1.0f, -1.0f), XMFLOAT4(0.0f, 1.0f, 0.0f, 1.0f) },
        { XMFLOAT3(1.0f, 1.0f, -1.0f), XMFLOAT4(0.0f, 0.0f, 1.0f, 1.0f) },
        { XMFLOAT3(-1.0f, 1.0f, -1.0f), XMFLOAT4(1.0f, 1.0f, 0.0f, 1.0f) },
        { XMFLOAT3(-1.0f, -1.0f, 1.0f), XMFLOAT4(1.0f, 0.0f, 1.0f, 1.0f) },
        { XMFLOAT3(1.0f, -1.0f, 1.0f), XMFLOAT4(0.0f, 1.0f, 1.0f, 1.0f) },
        { XMFLOAT3(1.0f, 1.0f, 1.0f), XMFLOAT4(1.0f, 1.0f, 1.0f, 1.0f) },
        { XMFLOAT3(-1.0f, 1.0f, 1.0f), XMFLOAT4(0.0f, 0.0f, 0.0f, 1.0f) },
    };

    UINT indices[] = {
        0, 1, 2, 2, 3, 0,
        4, 5, 6, 6, 7, 4,
        0, 1, 5, 5, 4, 0,
        2, 3, 7, 7, 6, 2,
        1, 2, 6, 6, 5, 1,
        3, 0, 4, 4, 7, 3
    };

    indexCount = sizeof(indices) / sizeof(indices[0]);

    // Create vertex buffer
    // (Buffer creation code goes here)


    // Create index buffer
    // (Buffer creation code goes here)
}

void Cube::update(float deltaTime) {
    rotationAngle += deltaTime;
}

void Cube::draw(ID3D12GraphicsCommandList* commandList) {
    // Set vertex and index buffers
    // (Binding code goes here)

    // Draw the cube
    commandList->DrawIndexedInstanced(indexCount, 1, 0, 0, 0);
}
