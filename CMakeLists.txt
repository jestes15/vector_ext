cmake_minimum_required (VERSION 3.9)
project (CPP_PLAYGROUND)
# set (CMAKE_CXX_COMPILER "/usr/local/gcc-11.2.0/bin/g++-11.2")
set (CMAKE_CXX_COMPILER "/usr/bin/clang++")

# set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -fopenmp --std=c++20")
# set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 --std=c++20")

# set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -fopenmp -ffast-math --std=c++20")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -ffast-math --std=c++20")

add_executable (main main.cpp)
target_link_libraries(main)
