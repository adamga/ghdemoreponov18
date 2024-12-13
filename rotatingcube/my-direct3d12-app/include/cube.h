class Cube {
public:
    Cube();
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