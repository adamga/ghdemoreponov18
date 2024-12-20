#include <d3d12.h>
#include <dxgi1_4.h>
#include <wrl.h>
#include <windows.h>



class Renderer {
public:
    Renderer();
    ~Renderer();

    bool initialize(HWND hwnd); // Change return type to bool
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
    IDXGISwapChain3* swapChain;
    ID3D12DescriptorHeap* rtvHeap;
    ID3D12Resource* renderTargets[2];
    ID3D12PipelineState* pipelineState;
    ID3D12GraphicsCommandList* commandList;
    UINT rtvDescriptorSize;
    HANDLE fenceEvent;
    UINT64 fenceValue;
    ID3D12Fence* fence;
};
