class Renderer {
public:
    Renderer();
    ~Renderer();

    void initialize(HWND hwnd);
    void render();
    void cleanup();

private:
    void createDevice();
    void createSwapChain(HWND hwnd);
    void createCommandQueue();
    void createRenderTargetView();
    void createPipelineState();
    void createCommandList();
    void createFence();

    // Direct3D 12 resources
    ID3D12Device* device;
    ID3D12CommandQueue* commandQueue;
    ID3D12SwapChain* swapChain;
    ID3D12DescriptorHeap* rtvHeap;
    ID3D12Resource* renderTargets[2];
    ID3D12PipelineState* pipelineState;
    ID3D12GraphicsCommandList* commandList;
    UINT rtvDescriptorSize;
    HANDLE fenceEvent;
    UINT64 fenceValue;
    ID3D12Fence* fence;
};