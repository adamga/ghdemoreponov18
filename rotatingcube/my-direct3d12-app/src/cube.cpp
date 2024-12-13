#include "cube.h"
#include <d3d12.h>
#include <DirectXMath.h>

using namespace DirectX;

Cube::Cube(ID3D12Device* device) : m_device(device), m_vertexBuffer(nullptr), m_indexBuffer(nullptr), m_indexCount(0), m_rotation(0.0f) {
    createBuffers();
}

Cube::~Cube() {
    if (m_vertexBuffer) m_vertexBuffer->Release();
    if (m_indexBuffer) m_indexBuffer->Release();
}

void Cube::createBuffers() {
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

    m_indexCount = sizeof(indices) / sizeof(indices[0]);

    // Create vertex buffer
    // (Buffer creation code goes here)

    // Create index buffer
    // (Buffer creation code goes here)
}

void Cube::update(float deltaTime) {
    m_rotation += deltaTime;
}

void Cube::draw(ID3D12GraphicsCommandList* commandList) {
    // Set vertex and index buffers
    // (Binding code goes here)

    // Draw the cube
    commandList->DrawIndexedInstanced(m_indexCount, 1, 0, 0, 0);
}