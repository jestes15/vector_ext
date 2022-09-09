#include <vector>
#include <iostream>
#include <chrono>

#define USE_CUDA
#include "vector_ext.cuh"

template <typename T>
void print_array(std::vector<T> &array) {
    std::cout << "[ ";
    for (auto &i : array) {
        std::cout << i << " ";
    }
    std::cout << "]" << std::endl;
}

template <typename T>
int validate_dest(std_vec::vector_ext<T> &dest, std_vec::vector_ext<T> &src, std_vec::vector_ext<T> &src2) {
    for (int i = 0; i < dest.size(); i++) {
        if (dest[i] != src[i] + src2[i]) {
            std::cout << "Error at index " << i << std::endl;
            return 1;
        }
    }
    return 0;
}

int main()
{
    long size = 6000000;
    std_vec::vector_ext<int> src1(size), src2(size), dest(size);

    for (auto i = 0; i < size; ++i) {
        src1.push_back(i);
        src2.push_back(i);
    }

    auto start_for = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    for (long i = 0; i < size; ++i) {
        dest[i] = src1[i] + src2[i];
    }
    auto end_for = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    std::cout << "Time taken: " << (end_for - start_for) << "ms" << std::endl;


    auto start = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    dest = src1 + src2;
    auto stop = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

    std::cout << "Time taken: " << (stop - start) << "ms" << std::endl;

    if (validate_dest(dest, src1, src2)) {
        return 1;
    }

    std_vec::vector_ext<int> src(20);
    src.generate_random_list_cuda(10000);

    print_array(src);

    return 0;
}