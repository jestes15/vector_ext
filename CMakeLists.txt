cmake_minimum_required (VERSION 3.20)
project (CPP_PLAYGROUND)

set (CMAKE_CXX_COMPILER "clang++-10")
set (CMAKE_CXX_FLAGS "-O3 -std=c++20")

add_executable (main main.cpp)
target_link_libraries(main)
