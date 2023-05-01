#include <chrono>
#include <iostream>
#include <vector>

#include "cuda.h"
#include "curand.h"

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define USE_CUDA
#define MATRIX_MUL
#include "kernel_impl.cuh"
#include "vector_ext.cuh"

#include <unordered_set>

template <typename T> void print_array(std::vector<T> &array)
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
int something()
{
    int iLen(1024);
    long long *device_result;
    long long result[iLen] = {0};

    CUDA_CALL(cudaMalloc(reinterpret_cast<long long **>(&device_result), sizeof(long long) * iLen));

    CUDA_CALL(cudaMemcpy(device_result, result, sizeof(long long) * iLen, cudaMemcpyHostToDevice));

    dim3 block(iLen);
    dim3 grid((iLen + block.x - 1) / block.x);

    auto start =
        std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch())
            .count();
    std_vec::kernel::mystery_kernel<<<grid, block>>>(device_result);
    auto stop =
        std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch())
            .count();

    CUDA_CALL(cudaDeviceSynchronize());

    CUDA_CALL(cudaMemcpy(result, device_result, sizeof(long long) * iLen, cudaMemcpyDeviceToHost));

    CUDA_CALL(cudaFree(device_result));

    std::cout << stop - start << std::endl;

    return EXIT_SUCCESS;
}

#if defined(MATRIX_MUL)
// TODO: Finish test for user_space::matrix_mul
void _test()
{
    const int size = 4;

    auto src = new int[size * size];
    auto src2 = new int[size * size];
    auto dest = new int[size * size];

    std::random_device gen;
    std::uniform_int_distribution<int> dist(0, 20);

    std::for_each_n(src, size * size, [&dist, &gen](int &i) { i = static_cast<int>(dist(gen)); });

    std::for_each_n(src2, size * size, [&dist, &gen](int &i) { i = static_cast<int>(dist(gen)); });

    for (unsigned long long i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            printf("%d\t", src[i * size + j]);
        }
        printf("\n");
    }
    printf("\n");

    for (unsigned long long i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            printf("%d\t", src2[i * size + j]);
        }
        printf("\n");
    }
    printf("\n");

    std_vec::user_space::matrix_mul(dest, src, src2, size, size, size, size);

    for (unsigned long long i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            printf("%d\t", dest[i * size + j]);
        }
        printf("\n");
    }
    printf("\n");
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

    auto start_for =
        std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch())
            .count();
    for (long i = 0; i < size; ++i)
    {
        dest[i] = src1[i] + src2[i];
    }
    auto end_for =
        std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch())
            .count();
    std::cout << "Time taken: " << (end_for - start_for) << "ms" << std::endl;

    auto start =
        std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch())
            .count();
    dest = src1 + src2;
    auto stop =
        std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch())
            .count();

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
} // namespace tests

int main()
{
    #ifdef USE_CUDA
    tests::_test();
    #endif

    return 0;
}