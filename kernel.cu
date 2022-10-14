#include <vector>
#include <iostream>
#include <chrono>

#define USE_CUDA
#include "vector_ext.cuh"

template <typename T>
void print_array(std::vector<T> &array)
{
    std::cout << "[ ";
    for (auto &i : array)
    {
        std::cout << i << " ";
    }
    std::cout << "]" << std::endl;
}

template <typename T>
int validate_dest(std_vec::vector_ext<T> &dest, std_vec::vector_ext<T> &src, std_vec::vector_ext<T> &src2)
{
    for (int i = 0; i < dest.size(); i++)
    {
        if (dest[i] != src[i] + src2[i])
        {
            std::cout << "Error at index " << i << std::endl;
            return 1;
        }
    }
    return 0;
}
namespace tests
{
    #if defined(MATRIX_MUL)
    // TODO: Finish test for user_space::matrix_mul
    void _test()
    {
        const int size = 10;

        auto src = new int [size][size];
        auto src2 = new int [size][size];
        auto dest = new int [size][size];

        std::random_device gen;
        std::uniform_int_distribution<int> dist(-300, 300);

        std::for_each_n(src, size, [&dist, &gen](int *row) {
            std::for_each_n(row, size, [&dist, &gen](int &i) {
                i = static_cast<int>(dist(gen));
            });
        });

        std::for_each_n(src2, size, [&dist, &gen](int *row) {
            std::for_each_n(row, size, [&dist, &gen](int &i) {
                i = static_cast<int>(dist(gen));
            });
        });

        std::for_each_n(src, size, [](int *row) {
            std::for_each_n(row, size, [](int &i) {
                std::cout << i << " ";
            });
            std::cout << std::endl;
        });

        user_space::matrix_mul(dest, src, src2, size, size, size, size);

        std::for_each_n(dest, size, [](int *row) {
            std::for_each_n(row, size, [](int &i) {
                std::cout << i << " ";
            });
            std::cout << std::endl;
        });

    }
    #endif

    int t()
    {
        long size = 6000000;
        std_vec::vector_ext<int> src1(size), src2(size), dest(size);

        for (auto i = 0; i < size; ++i)
        {
            src1.push_back(i);
            src2.push_back(i);
        }

        auto start_for = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
        for (long i = 0; i < size; ++i)
        {
            dest[i] = src1[i] + src2[i];
        }
        auto end_for = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
        std::cout << "Time taken: " << (end_for - start_for) << "ms" << std::endl;

        auto start = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
        dest = src1 + src2;
        auto stop = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

        std::cout << "Time taken: " << (stop - start) << "ms" << std::endl;

        if (validate_dest(dest, src1, src2))
        {
            return 1;
        }

        std_vec::vector_ext<int> src(20);
        src.generate_random_list_cuda(10000);

        print_array(src);

        return 0;
    }
}

int main()
{
    #if defined(MATRIX_MUL)
    tests::_test();
    #endif

    return 0;
}