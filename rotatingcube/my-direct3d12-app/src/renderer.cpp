#include "renderer.h"
#include <stdexcept>
#include <d3dx12.h> // Include the necessary header for CD3DX12 classes

Renderer::Renderer() {
    // Constructor implementation

    device = nullptr;
    commandQueue = nullptr;

    swapChain = nullptr;
    rtvHeap = nullptr;
    pipelineState = nullptr;
    commandList = nullptr;
    fence = nullptr;
    fenceEvent = nullptr;
    fenceValue = 0;

    for (int i = 0; i < 2; i++) {
        renderTargets[i] = nullptr;
        commandAllocator[i] = nullptr; // Initialize commandAllocator
    }

    rtvDescriptorSize = 0;
}

Renderer::~Renderer() {
    // Destructor implementation

    if (device) device->Release();
    if (commandQueue) commandQueue->Release();
    if (swapChain) swapChain->Release();
    if (rtvHeap) rtvHeap->Release();
    if (pipelineState) pipelineState->Release();
    if (commandList) commandList->Release();
    if (fence) fence->Release();
    if (fenceEvent) CloseHandle(fenceEvent);

    for (int i = 0; i < 2; i++) {
        if (commandAllocator[i]) commandAllocator[i]->Release();
    }
}

bool Renderer::initialize(HWND hwnd) {
    try {
        createDevice();
        createSwapChain(hwnd);
        createCommandQueue();
        createRenderTargetView();
        createPipelineState();
        createCommandList();
        createFence();
        return true;
    }
    catch (...) {
        return false;
    }
}

void Renderer::render() {
    // Render implementation

    // Wait for the previous frame to complete
    const UINT64 currentFenceValue = fenceValue;
    commandQueue->Signal(fence, currentFenceValue);
    fenceValue++;

    if (fence->GetCompletedValue() < currentFenceValue) {
        fence->SetEventOnCompletion(currentFenceValue, fenceEvent);
        WaitForSingleObject(fenceEvent, INFINITE);
    }

    // Get the index of the current back buffer
    const UINT backBufferIndex = swapChain->GetCurrentBackBufferIndex();

    // Record commands
    commandAllocator[backBufferIndex]->Reset(); // Reset the command allocator
    commandList->Reset(commandAllocator[backBufferIndex], nullptr);
    commandList->ResourceBarrier(1, &CD3DX12_RESOURCE_BARRIER::Transition(renderTargets[backBufferIndex], D3D12_RESOURCE_STATE_PRESENT, D3D12_RESOURCE_STATE_RENDER_TARGET));
    CD3DX12_CPU_DESCRIPTOR_HANDLE rtvHandle(rtvHeap->GetCPUDescriptorHandleForHeapStart(), backBufferIndex, rtvDescriptorSize);
    commandList->OMSetRenderTargets(1, &rtvHandle, FALSE, nullptr);
    const float clearColor[] = { 0.0f, 0.2f, 0.4f, 1.0f };
    commandList->ClearRenderTargetView(rtvHandle, clearColor, 0, nullptr);
    commandList->SetPipelineState(pipelineState);
    commandList->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);

    // Execute the command list
    commandList->Close();
    ID3D12CommandList* ppCommandLists[] = { commandList };
    commandQueue->ExecuteCommandLists(_countof(ppCommandLists), ppCommandLists);

    // Present the frame
    swapChain->Present(1, 0);

    // Signal and increment the fence value
    commandQueue->Signal(fence, fenceValue);
}

void Renderer::cleanup() {
    // Cleanup implementation
}

void Renderer::createDevice() {
    // Create device implementation
}

void Renderer::createSwapChain(HWND hwnd) {
    // Create swap chain implementation
}

void Renderer::createCommandQueue() {
    // Create command queue implementation
}

void Renderer::createRenderTargetView() {
    // Create render target view implementation
}

void Renderer::createPipelineState() {
    // Create pipeline state implementation
}

void Renderer::createCommandList() {
    // Create command list implementation
}

void Renderer::createFence() {
    // Create fence implementation
    HRESULT hr = device->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&fence));
    if (FAILED(hr)) {
        throw std::runtime_error("Failed to create fence.");
    }

    fenceValue = 1;

    // Create an event handle to use for frame synchronization
    fenceEvent = CreateEvent(nullptr, FALSE, FALSE, nullptr);
    if (fenceEvent == nullptr) {
        throw std::runtime_error("Failed to create fence event.");
    }
}
