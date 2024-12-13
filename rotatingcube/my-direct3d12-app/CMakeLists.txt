cmake_minimum_required(VERSION 3.14)

project(MyDirect3D12App)

set(CMAKE_CXX_STANDARD 17)

# Include directories
include_directories(include)

# Include DirectX headers
include_directories("C:/Program Files (x86)/Windows Kits/10/Include/10.0.22621.0/um")

# Source files
set(SOURCES
    src/main.cpp
    src/renderer.cpp
    src/cube.cpp
)

# Add executable
add_executable(MyDirect3D12App ${SOURCES})

# Link DirectX libraries
target_link_libraries(MyDirect3D12App d3d12 dxgi dxguid)