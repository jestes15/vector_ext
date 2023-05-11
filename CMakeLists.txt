cmake_minimum_required(VERSION 3.16)

project(vector_ext LANGUAGES CUDA CXX VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)

find_package(CUDAToolkit REQUIRED curand)
find_package(OpenMP REQUIRED)
find_package(TBB REQUIRED)

include_directories(include)

add_executable(kernel_impl_test src/kernel_implementation_tests.cu)
set_target_properties(kernel_impl_test PROPERTIES CUDA_ARCHITECTURES "72")
target_link_libraries(kernel_impl_test CUDA::curand)

add_executable(quaternion_test src/quaternion_test.cu)
set_target_properties(quaternion_test PROPERTIES CUDA_ARCHITECTURES "72")
target_link_libraries(quaternion_test CUDA::curand)

add_executable(vector_ext_test src/vector_ext_test.cu)
set_target_properties(vector_ext_test PROPERTIES CUDA_ARCHITECTURES "72")
target_link_libraries(vector_ext_test CUDA::curand TBB::tbb)