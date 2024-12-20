#include <wrl/client.h>
#include <d3d12.h>

class Cube {
public:
    Cube(ID3D12Device* device); // Add this constructor declaration
    ~Cube();

    void createBuffers(ID3D12Device* device);
    void update(float deltaTime);
    void draw(ID3D12GraphicsCommandList* commandList);

private:
    Microsoft::WRL::ComPtr<ID3D12Resource> vertexBuffer;
    Microsoft::WRL::ComPtr<ID3D12Resource> indexBuffer;
    UINT indexCount;
    float rotationAngle;
};
