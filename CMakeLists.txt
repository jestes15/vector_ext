cmake_minimum_required(VERSION 3.16)

project(vector_ext LANGUAGES CUDA)

set(CMAKE_CXX_STANDARD 17)

find_package(CUDAToolkit REQUIRED curand)

include_directories(include)

add_executable(vector_ext src/kernel.cu)
set_target_properties(vector_ext PROPERTIES CUDA_ARCHITECTURES "72")
set_property(TARGET vector_ext PROPERTY CUDA_STANDARD 20)
target_link_libraries(vector_ext CUDA::curand)

add_executable(vector_ext_test src/test.cu)
set_target_properties(vector_ext_test PROPERTIES CUDA_ARCHITECTURES "72")
set_property(TARGET vector_ext_test PROPERTY CUDA_STANDARD 20)
target_link_libraries(vector_ext_test CUDA::curand)