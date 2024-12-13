# My Direct3D 12 App

This project is a simple application that demonstrates how to create a rotating cube in 3D using Direct3D 12. It serves as an introduction to graphics programming with Direct3D 12 and showcases the basic setup required for rendering 3D objects.

## Project Structure

```
my-direct3d12-app
├── src
│   ├── main.cpp          # Entry point of the application
│   ├── renderer.cpp      # Implementation of the Renderer class
│   └── cube.cpp          # Implementation of the Cube class
├── include
│   ├── renderer.h        # Header file for the Renderer class
│   └── cube.h            # Header file for the Cube class
├── shaders
│   ├── vertex_shader.hlsl # HLSL code for the vertex shader
│   └── pixel_shader.hlsl  # HLSL code for the pixel shader
├── CMakeLists.txt        # CMake configuration file
└── .gitignore            # Git ignore file
```

## Building the Project

To build the project, you need to have CMake installed. Follow these steps:

1. Clone the repository or download the project files.
2. Open a terminal and navigate to the project directory.
3. Create a build directory:
   ```
   mkdir build
   cd build
   ```
4. Run CMake to configure the project:
   ```
   cmake ..
   ```
5. Build the project:
   ```
   cmake --build .
   ```

## Running the Application

After building the project, you can run the application from the build directory. The application will create a window displaying a rotating cube.

## Dependencies

This project requires the Windows SDK and Direct3D 12 to be installed on your system.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.