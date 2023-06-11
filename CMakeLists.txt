cmake_minimum_required(VERSION 3.16)

if (NOT DEFINED ${CMAKE_CXX_COMPILER})
    set(CMAKE_CXX_COMPILER /usr/bin/g++)
endif()
message(STATUS "CMAKE_CXX_COMPILER set to ${CMAKE_CXX_COMPILER}")

if(NOT DEFINED ${CMAKE_CUDA_COMPILER})
    set(CMAKE_CUDA_COMPILER /usr/local/cuda/bin/nvcc)
endif()
message(STATUS "CMAKE_CUDA_COMPILER set to ${CMAKE_CUDA_COMPILER}")

if(NOT DEFINED ${CMAKE_CUDA_ARCHITECTURES})
    set(CMAKE_CUDA_ARCHITECTURES 72)
endif()
message(STATUS "CUDA architectures set to ${CMAKE_CUDA_ARCHITECTURES}")

if(NOT DEFINED ${CMAKE_CXX_STANDARD})
    set(CMAKE_CXX_STANDARD 17)
endif()
message(STATUS "CMAKE_CXX_STANDARD set to ${CMAKE_CXX_STANDARD}")

project(vector_ext LANGUAGES CUDA CXX VERSION 1.0.0)

find_package(CUDAToolkit REQUIRED curand)
find_package(OpenMP REQUIRED)
find_package(TBB REQUIRED)

include_directories(include)

add_executable(kernel_impl_test src/kernel_implementation_tests.cu)
target_link_libraries(kernel_impl_test CUDA::curand)

add_executable(quaternion_test src/quaternion_test.cu)
target_link_libraries(quaternion_test)

add_executable(vector_ext_test_cuda src/vector_ext_cuda_test.cu)
target_link_libraries(vector_ext_test_cuda CUDA::curand)

add_executable(vector_ext_test_openmp src/vector_ext_openmp_test.cu)
target_link_libraries(vector_ext_test_openmp OpenMP::OpenMP_CXX)

add_executable(vector_ext_test_execution src/vector_ext_execution_policy_test.cu)
target_link_libraries(vector_ext_test_execution TBB::tbb)