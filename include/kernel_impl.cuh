#ifndef KERNEL_IMPL
#define KERNEL_IMPL

#include <array>
#include <iostream>

#include "types.cuh"

#include "cuda.h"
#include "curand.h"

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

namespace cuda_checks
{
// CUDA return value checks
std::string CUDA_CHECK_VAL(cudaError_t);
std::string CURAND_CHECK_VAL(curandStatus_t);
} // namespace cuda_checks
const i32 TILE_WIDTH = 32;

// Check method for checking the error status of a CUDA call
#define CUDA_CALL(x)                                                                                                   \
    {                                                                                                                  \
        if (x != cudaSuccess)                                                                                          \
        {                                                                                                              \
            std::cout << "Error: " << cuda_checks::CUDA_CHECK_VAL(x) << " at " << __FILE__ << ":" << __LINE__          \
                      << std::endl;                                                                                    \
            return EXIT_FAILURE;                                                                                       \
        }                                                                                                              \
    }

// Check method for checking the error status of a cuRAND call
#define CURAND_CALL(x)                                                                                                 \
    {                                                                                                                  \
        if (x != CURAND_STATUS_SUCCESS)                                                                                \
        {                                                                                                              \
            std::cout << "Error: " << cuda_checks::CURAND_CHECK_VAL(x) << " at " << __FILE__ << ":" << __LINE__        \
                      << std::endl;                                                                                    \
            return EXIT_FAILURE;                                                                                       \
        }                                                                                                              \
    }

// std_vec namespace
namespace std_vec
{
// Implemntation of kernels
namespace kernel
{
// Kernel for adding two arrays
template <typename _Type> __global__ void add_kernel(_Type *dest, _Type *src_1, _Type *src_2, u64 size)
{
    i64 id = blockDim.x * blockIdx.x + threadIdx.x;
    i64 stride = blockDim.x * gridDim.x;

    for (std::size_t i = id; i < size; i += stride)
        dest[i] = src_1[i] + src_2[i];
}

// Kernel for subtracting two arrays
template <typename _Type> __global__ void sub_kernel(_Type *dest, _Type *src_1, _Type *src_2, u64 size)
{
    i64 id = blockDim.x * blockIdx.x + threadIdx.x;
    i64 stride = blockDim.x * gridDim.x;

    for (std::size_t i = id; i < size; i += stride)
    {
        dest[i] = src_1[i] - src_2[i];
    }
}

// Kernel for multiplying two arrays
template <typename _Type> __global__ void mul_kernel(_Type *dest, _Type *src_1, _Type *src_2, u64 size)
{
    i64 id = blockDim.x * blockIdx.x + threadIdx.x;
    i64 stride = blockDim.x * gridDim.x;

    for (std::size_t i = id; i < size; i += stride)
    {
        dest[i] = src_1[i] * src_2[i];
    }
}

// Kernel for dividing two arrays
template <typename _Type> __global__ void div_kernel(_Type *dest, _Type *src_1, _Type *src_2, u64 size)
{
    i64 id = blockDim.x * blockIdx.x + threadIdx.x;
    i64 stride = blockDim.x * gridDim.x;

    for (std::size_t i = id; i < size; i += stride)
    {
        dest[i] = src_1[i] / src_2[i];
    }
}

// Kernel to bring more digits into the non-floating poi32 space
template <typename _Type>
__global__ void make_float_larger(_Type *dest, f32 *device_float_src, u64 size, u64 float_shift)
{
    i64 id = blockDim.x * blockIdx.x + threadIdx.x;
    i64 stride = blockDim.x * gridDim.x;

    for (std::size_t i = id; i < size; i += stride)
    {
        dest[i] = static_cast<_Type>(device_float_src[i] * float_shift);
    }
}

// Kernel to bring the digits within the max value of the non-floating poi32 space
template <typename _Type> __global__ void bring_random_below_max(_Type *dest, u64 size, i64 max)
{
    i64 id = blockDim.x * blockIdx.x + threadIdx.x;
    i64 stride = blockDim.x * gridDim.x;

    for (std::size_t i = id; i < size; i += stride)
    {
        dest[i] %= max;
    }
}

// Kernel to impliment matrix multiplication on nxn matrix
template <typename _Type>
__global__ void matrix_mul(_Type *dest, _Type *src_1, _Type *src_2, i32 dest_row, i32 dest_col, i32 src_1_row,
                           i32 src_1_col, i32 src_2_row, i32 src_2_col)
{
    __shared__ _Type sA[TILE_WIDTH][TILE_WIDTH];
    __shared__ _Type sB[TILE_WIDTH][TILE_WIDTH];

    i64 Row = blockDim.y * blockIdx.y + threadIdx.y;
    i64 Col = blockDim.x * blockIdx.x + threadIdx.x;
    _Type val = static_cast<_Type>(0.0);
    sA[threadIdx.y][threadIdx.x] = static_cast<_Type>(0.0);
    sB[threadIdx.y][threadIdx.x] = static_cast<_Type>(0.0);

    for (u64 ph = 0; ph < (((src_1_col - 1) / TILE_WIDTH) + 1); ph++)
    {
        if ((Row < src_1_row) && (threadIdx.x + (ph * TILE_WIDTH)) < src_1_col)
        {
            sA[threadIdx.y][threadIdx.x] = src_1[(Row * src_1_col) + threadIdx.x + (ph * TILE_WIDTH)];
        }
        else
        {
            sA[threadIdx.y][threadIdx.x] = static_cast<_Type>(0.0);
        }
        if (Col < src_2_col && (threadIdx.y + ph * TILE_WIDTH) < src_2_row)
        {
            sB[threadIdx.y][threadIdx.x] = src_2[(threadIdx.y + ph * TILE_WIDTH) * src_2_col + Col];
        }
        else
        {
            sB[threadIdx.y][threadIdx.x] = static_cast<_Type>(0.0);
        }
        __syncthreads();

        for (u64 j = 0; j < TILE_WIDTH; ++j)
        {
            val += sA[threadIdx.y][j] * sB[j][threadIdx.x];
        }
    }
    if (Row < dest_row && Col < dest_col)
    {
        dest[Row * dest_col + Col] = val;
    }
}
} // namespace kernel

namespace auxillary
{
template <typename _DestType, typename _SrcType>
void squish(_DestType *dest, _SrcType **src, std::size_t column, std::size_t row)
{
    for (std::size_t i = 0; i < row; i++)
    {
        for (std::size_t j = 0; j < column; j++)
        {
            dest[i * column + j] = static_cast<_DestType>(src[i][j]);
        }
    }
}

template <typename _DestType, typename _SrcType>
void unsquish(_DestType **dest, _SrcType *src, std::size_t column, std::size_t row)
{
    for (std::size_t i = 0; i < row; i++)
    {
        for (std::size_t j = 0; j < column; j++)
        {
            dest[i][j] = static_cast<_DestType>(src[i * column + j]);
        }
    }
}
} // namespace auxillary

namespace user_space
{
namespace
{
// Driver code to handle setting up the device and calling the kernel for addition
template <typename _Type> i32 add_raw(_Type *dest, _Type *src_1, _Type *src_2, std::size_t size_v)
{
    _Type *device_src_1, *device_src_2, *device_dest;
    i32 iLen(1024);

    u64 size = size_v;

    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_1), sizeof(_Type) * size));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_2), sizeof(_Type) * size));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_dest), sizeof(_Type) * size));

    CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(_Type) * size, cudaMemcpyHostToDevice));
    CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(_Type) * size, cudaMemcpyHostToDevice));

    dim3 block(iLen);
    dim3 grid((size + block.x - 1) / block.x);

    kernel::add_kernel<<<grid, block>>>(device_dest, device_src_1, device_src_2, size);

    CUDA_CALL(cudaDeviceSynchronize());

    CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(_Type) * size, cudaMemcpyDeviceToHost));

    CUDA_CALL(cudaFree(device_src_1));
    CUDA_CALL(cudaFree(device_src_2));
    CUDA_CALL(cudaFree(device_dest));

    return EXIT_SUCCESS;
}

// Driver code to handle setting up the device and calling the kernel for subtraction
template <typename _Type> i32 sub_raw(_Type *dest, _Type *src_1, _Type *src_2, std::size_t size)
{
    _Type *device_src_1, *device_src_2, *device_dest;
    i32 iLen(1024);

    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_1), sizeof(_Type) * size));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_2), sizeof(_Type) * size));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_dest), sizeof(_Type) * size));

    CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(_Type) * size, cudaMemcpyHostToDevice));
    CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(_Type) * size, cudaMemcpyHostToDevice));

    dim3 block(iLen);
    dim3 grid((size + block.x - 1) / block.x);

    kernel::sub_kernel<<<grid, block>>>(device_dest, device_src_1, device_src_2, size);

    CUDA_CALL(cudaDeviceSynchronize());

    CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(_Type) * size, cudaMemcpyDeviceToHost));

    CUDA_CALL(cudaFree(device_src_1));
    CUDA_CALL(cudaFree(device_src_2));
    CUDA_CALL(cudaFree(device_dest));

    return EXIT_SUCCESS;
}

// Driver code to handle setting up the device and calling the kernel for multiplication
template <typename _Type> i32 mul_raw(_Type *dest, _Type *src_1, _Type *src_2, std::size_t size)
{
    _Type *device_src_1, *device_src_2, *device_dest;
    i32 iLen(1024);

    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_1), sizeof(_Type) * size));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_2), sizeof(_Type) * size));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_dest), sizeof(_Type) * size));

    CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(_Type) * size, cudaMemcpyHostToDevice));
    CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(_Type) * size, cudaMemcpyHostToDevice));

    dim3 block(iLen);
    dim3 grid((size + block.x - 1) / block.x);

    kernel::mul_kernel<<<grid, block>>>(device_dest, device_src_1, device_src_2, size);

    CUDA_CALL(cudaDeviceSynchronize());

    CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(_Type) * size, cudaMemcpyDeviceToHost));

    CUDA_CALL(cudaFree(device_src_1));
    CUDA_CALL(cudaFree(device_src_2));
    CUDA_CALL(cudaFree(device_dest));

    return EXIT_SUCCESS;
}

// Driver code to handle setting up the device and calling the kernel for division
template <typename _Type> i32 div_raw(_Type *dest, _Type *src_1, _Type *src_2, std::size_t size)
{
    _Type *device_src_1, *device_src_2, *device_dest;
    i32 iLen(1024);

    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_1), sizeof(_Type) * size));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_2), sizeof(_Type) * size));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_dest), sizeof(_Type) * size));

    CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(_Type) * size, cudaMemcpyHostToDevice));
    CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(_Type) * size, cudaMemcpyHostToDevice));

    dim3 block(iLen);
    dim3 grid((size + block.x - 1) / block.x);

    kernel::div_kernel<<<grid, block>>>(device_dest, device_src_1, device_src_2, size);

    CUDA_CALL(cudaDeviceSynchronize());

    CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(_Type) * size, cudaMemcpyDeviceToHost));

    CUDA_CALL(cudaFree(device_src_1));
    CUDA_CALL(cudaFree(device_src_2));
    CUDA_CALL(cudaFree(device_dest));

    return EXIT_SUCCESS;
}

template <typename _Type> i32 generate_random_number_raw(_Type *dest, std::size_t size, i32 float_shift, i32 max)
{
    float *random_number_gen_dest;
    _Type *device_dest_int;
    i32 iLen(1024);

    curandGenerator_t gen;
    dim3 block(iLen);
    dim3 grid((size + block.x - 1) / block.x);

    CUDA_CALL(cudaMalloc(reinterpret_cast<float **>(&random_number_gen_dest), sizeof(float) * size))
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_dest_int), sizeof(_Type) * size))

    CURAND_CALL(curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT))
    CURAND_CALL(curandSetPseudoRandomGeneratorSeed(gen, time(NULL)))
    CURAND_CALL(curandGenerateUniform(gen, random_number_gen_dest, size))

    kernel::make_float_larger<<<grid, block>>>(device_dest_int, random_number_gen_dest, size, float_shift);
    kernel::bring_random_below_max<<<grid, block>>>(device_dest_int, size, max);

    CUDA_CALL(cudaDeviceSynchronize())

    CUDA_CALL(cudaMemcpy(dest, device_dest_int, sizeof(_Type) * size, cudaMemcpyDeviceToHost))

    CUDA_CALL(cudaFree(random_number_gen_dest))
    CUDA_CALL(cudaFree(device_dest_int))

    return EXIT_SUCCESS;
}
template <typename _Type>
i32 generate_random_number_raw(_Type *dest, std::size_t size, i32 float_shift, i32 max, i32 seed)
{
    float *random_number_gen_dest;
    _Type *device_dest_int;
    i32 iLen(1024);

    curandGenerator_t gen;
    dim3 block(iLen);
    dim3 grid((size + block.x - 1) / block.x);

    CUDA_CALL(cudaMalloc(reinterpret_cast<float **>(&random_number_gen_dest), sizeof(float) * size))
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_dest_int), sizeof(_Type) * size))

    CURAND_CALL(curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT))
    CURAND_CALL(curandSetPseudoRandomGeneratorSeed(gen, seed))
    CURAND_CALL(curandGenerateUniform(gen, random_number_gen_dest, size))

    kernel::make_float_larger<<<grid, block>>>(device_dest_int, random_number_gen_dest, size, float_shift);
    kernel::bring_random_below_max<<<grid, block>>>(device_dest_int, size, max);

    CUDA_CALL(cudaDeviceSynchronize())

    CUDA_CALL(cudaMemcpy(dest, device_dest_int, sizeof(_Type) * size, cudaMemcpyDeviceToHost))

    CUDA_CALL(cudaFree(random_number_gen_dest))
    CUDA_CALL(cudaFree(device_dest_int))

    return EXIT_SUCCESS;
}

} // namespace

template <typename _Type, std::size_t size>
i32 add(std::array<_Type, size> &dest, std::array<_Type, size> &src_1, std::array<_Type, size> &src_2)
{
    std::size_t free_vram, total_vram;
    cudaMemGetInfo(&free_vram, &total_vram);

    if (free_vram < (sizeof(_Type) * size * 3))
        return EXIT_FAILURE;

    return add_raw(dest.data(), src_1.data(), src_2.data(), size);
}

template <typename _Type, std::size_t size>
i32 sub(std::array<_Type, size> &dest, std::array<_Type, size> &src_1, std::array<_Type, size> &src_2)
{
    std::size_t free_vram, total_vram;
    cudaMemGetInfo(&free_vram, &total_vram);

    if (free_vram < (sizeof(_Type) * size * 3))
        return EXIT_FAILURE;

    return sub_raw(dest.data(), src_1.data(), src_2.data(), size);
}

template <typename _Type, std::size_t size>
i32 mul(std::array<_Type, size> &dest, std::array<_Type, size> &src_1, std::array<_Type, size> &src_2)
{
    std::size_t free_vram, total_vram;
    cudaMemGetInfo(&free_vram, &total_vram);

    if (free_vram < (sizeof(_Type) * size * 3))
        return EXIT_FAILURE;

    return mul_raw(dest.data(), src_1.data(), src_2.data(), size);
}

template <typename _Type, std::size_t size>
i32 div(std::array<_Type, size> &dest, std::array<_Type, size> &src_1, std::array<_Type, size> &src_2)
{
    std::size_t free_vram, total_vram;
    cudaMemGetInfo(&free_vram, &total_vram);

    if (free_vram < (sizeof(_Type) * size * 3))
        return EXIT_FAILURE;

    return div_raw(dest.data(), src_1.data(), src_2.data(), size);
}

// Driver code to handle setting up the device and calling the kernel for geberating random numbers
template <typename _Type, std::size_t size>
i32 generate_random_number(std::array<_Type, size> dest, i32 float_shift, i32 max)
{
    std::size_t free_vram, total_vram;
    cudaMemGetInfo(&free_vram, &total_vram);

    if (free_vram < (sizeof(_Type) * size))
        return EXIT_FAILURE;

    return generate_random_number_raw(dest.data(), size, float_shift, max);
}

template <typename _Type, std::size_t size>
i32 generate_random_number(std::array<_Type, size> dest, i32 float_shift, i32 max, i32 seed)
{
    std::size_t free_vram, total_vram;
    cudaMemGetInfo(&free_vram, &total_vram);

    if (free_vram < (sizeof(_Type) * size))
        return EXIT_FAILURE;

    return generate_random_number_raw(dest.data(), size, float_shift, max, seed);
}

// Driver code to handle setting up the device and calling the kernel for matrix multiplication
// Matrices already squished into 1d arrays
template <typename _Type>
i32 matrix_mul(_Type *dest, _Type *src_1, _Type *src_2, u32 rows_src_1, u32 columns_src_1, u32 rows_src_2,
               u32 columns_src_2)
{
    _Type *device_src_1, *device_src_2, *device_dest;

    u64 dest_rows = rows_src_1;
    u64 dest_columns = columns_src_2;

    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_1), sizeof(_Type) * rows_src_1 * columns_src_1));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_2), sizeof(_Type) * rows_src_2 * columns_src_2));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_dest), sizeof(_Type) * rows_src_1 * columns_src_2));

    CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(_Type) * rows_src_1 * columns_src_1, cudaMemcpyHostToDevice));
    CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(_Type) * rows_src_2 * columns_src_2, cudaMemcpyHostToDevice));

    dim3 dimBlock(TILE_WIDTH, TILE_WIDTH, 1);
    dim3 dimGrid;

    dimGrid.x = (dest_columns / TILE_WIDTH) + 1;
    dimGrid.y = (dest_rows / TILE_WIDTH) + 1;
    dimGrid.z = 1;

    kernel::matrix_mul<<<dimGrid, dimBlock>>>(device_dest, device_src_1, device_src_2, dest_rows, dest_columns,
                                              rows_src_1, columns_src_1, rows_src_2, columns_src_2);

    CUDA_CALL(cudaDeviceSynchronize());

    CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(_Type) * rows_src_1 * columns_src_2, cudaMemcpyDeviceToHost));

    CUDA_CALL(cudaFree(device_src_1));
    CUDA_CALL(cudaFree(device_src_2));
    CUDA_CALL(cudaFree(device_dest));

    return EXIT_SUCCESS;
}

// Driver code to handle setting up the device and calling the kernel for matrix multiplication
// Matrices are not squished into 1d arrays, squishing will be done in function
template <typename _Type>
i32 matrix_mul(_Type **dest, _Type **src_1, _Type **src_2, u32 rows_src_1, u32 columns_src_1, u32 rows_src_2,
               u32 columns_src_2)
{
    _Type *device_src_1, *device_src_2, *device_dest;

    u64 dest_rows = rows_src_1;
    u64 dest_columns = columns_src_2;

    _Type *_dest, *_src_1, *_src_2;

    auxillary::squish(_dest, dest, dest_rows, dest_columns);
    auxillary::squish(_src_1, src_1, rows_src_1, columns_src_1);
    auxillary::squish(_src_2, src_2, rows_src_2, columns_src_2);

    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_1), sizeof(_Type) * rows_src_1 * columns_src_1));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_src_2), sizeof(_Type) * rows_src_2 * columns_src_2));
    CUDA_CALL(cudaMalloc(reinterpret_cast<_Type **>(&device_dest), sizeof(_Type) * rows_src_1 * columns_src_2));

    CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(_Type) * rows_src_1 * columns_src_1, cudaMemcpyHostToDevice));
    CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(_Type) * rows_src_2 * columns_src_2, cudaMemcpyHostToDevice));

    dim3 dimBlock(TILE_WIDTH, TILE_WIDTH, 1);
    dim3 dimGrid;

    dimGrid.x = (dest_columns / TILE_WIDTH) + 1;
    dimGrid.y = (dest_rows / TILE_WIDTH) + 1;
    dimGrid.z = 1;

    kernel::matrix_mul<<<dimGrid, dimBlock>>>(device_dest, device_src_1, device_src_2, dest_rows, dest_columns,
                                              rows_src_1, columns_src_1, rows_src_2, columns_src_2);

    CUDA_CALL(cudaDeviceSynchronize());

    CUDA_CALL(cudaMemcpy(_dest, device_dest, sizeof(_Type) * rows_src_1 * columns_src_2, cudaMemcpyDeviceToHost));

    auxillary::unsquish(dest, _dest, dest_rows, dest_columns);

    CUDA_CALL(cudaFree(device_src_1));
    CUDA_CALL(cudaFree(device_src_2));
    CUDA_CALL(cudaFree(device_dest));

    return EXIT_SUCCESS;
}
} // namespace user_space
} // namespace std_vec

namespace cuda_checks
{
// CUDA error check to get error name
std::string CUDA_CHECK_VAL(cudaError_t x)
{
    std::string msg;

    switch (x)
    {
    case 0:
        msg = "cudaSuccess";
    case 1:
        msg = "cudaErrorInvalidValue";
    case 2:
        msg = "cudaErrorMemoryAllocation";
    case 3:
        msg = "cudaErrorInitializationError";
    case 4:
        msg = "cudaErrorCudartUnloading";
    case 5:
        msg = "cudaErrorProfilerDisabled";
    case 9:
        msg = "cudaErrorInvalidConfiguration";
    case 12:
        msg = "cudaErrorInvalidPitchValue";
    case 13:
        msg = "cudaErrorInvalidSymbol";
    case 18:
        msg = "cudaErrorInvalidTexture";
    case 19:
        msg = "cudaErrorInvalidTextureBinding";
    case 20:
        msg = "cudaErrorInvalidChannelDescriptor";
    case 21:
        msg = "cudaErrorInvalidMemcpyDirection";
    case 26:
        msg = "cudaErrorInvalidFilterSetting";
    case 27:
        msg = "cudaErrorInvalidNormSetting";
    case 34:
        msg = "cudaErrorStubLibrary";
    case 35:
        msg = "cudaErrorInsufficientDriver";
    case 36:
        msg = "cudaErrorCallRequiresNewerDriver";
    case 37:
        msg = "cudaErrorInvalidSurface";
    case 43:
        msg = "cudaErrorDuplicateVariableName";
    case 44:
        msg = "cudaErrorDuplicateTextureName";
    case 45:
        msg = "cudaErrorDuplicateSurfaceName";
    case 46:
        msg = "cudaErrorDevicesUnavailable";
    case 49:
        msg = "cudaErrorIncompatibleDriverContext";
    case 52:
        msg = "cudaErrorMissingConfiguration";
    case 65:
        msg = "cudaErrorLaunchMaxDepthExceeded";
    case 66:
        msg = "cudaErrorLaunchFileScopedTex";
    case 67:
        msg = "cudaErrorLaunchFileScopedSurf";
    case 68:
        msg = "cudaErrorSyncDepthExceeded";
    case 69:
        msg = "cudaErrorLaunchPendingCountExceeded";
    case 98:
        msg = "cudaErrorInvalidDeviceFunction";
    case 100:
        msg = "cudaErrorNoDevice";
    case 101:
        msg = "cudaErrorInvalidDevice";
    case 102:
        msg = "cudaErrorDeviceNotLicensed";
    case 103:
        msg = "cudaErrorSoftwareValidityNotEstablished";
    case 127:
        msg = "cudaErrorStartupFailure";
    case 200:
        msg = "cudaErrorInvalidKernelImage";
    case 201:
        msg = "cudaErrorDeviceUninitialized";
    case 205:
        msg = "cudaErrorMapBufferObjectFailed";
    case 206:
        msg = "cudaErrorUnmapBufferObjectFailed";
    case 207:
        msg = "cudaErrorArrayIsMapped";
    case 208:
        msg = "cudaErrorAlreadyMapped";
    case 209:
        msg = "cudaErrorNoKernelImageForDevice";
    case 210:
        msg = "cudaErrorAlreadyAcquired";
    case 211:
        msg = "cudaErrorNotMapped";
    case 212:
        msg = "cudaErrorNotMappedAsArray";
    case 213:
        msg = "cudaErrorNotMappedAsPointer";
    case 214:
        msg = "cudaErrorECCUncorrectable";
    case 215:
        msg = "cudaErrorUnsupportedLimit";
    case 216:
        msg = "cudaErrorDeviceAlreadyInUse";
    case 217:
        msg = "cudaErrorPeerAccessUnsupported";
    case 218:
        msg = "cudaErrorInvalidPtx";
    case 219:
        msg = "cudaErrorInvalidGraphicsContext";
    case 220:
        msg = "cudaErrorNvlinkUncorrectable";
    case 221:
        msg = "cudaErrorJitCompilerNotFound";
    case 222:
        msg = "cudaErrorUnsupportedPtxVersion";
    case 223:
        msg = "cudaErrorJitCompilationDisabled";
    case 300:
        msg = "cudaErrorInvalidSource";
    case 301:
        msg = "cudaErrorFileNotFound";
    case 302:
        msg = "cudaErrorSharedObjectSymbolNotFound";
    case 303:
        msg = "cudaErrorSharedObjectInitFailed";
    case 304:
        msg = "cudaErrorOperatingSystem";
    case 400:
        msg = "cudaErrorInvalidResourceHandle";
    case 401:
        msg = "cudaErrorIllegalState";
    case 500:
        msg = "cudaErrorSymbolNotFound";
    case 600:
        msg = "cudaErrorNotReady";
    case 700:
        msg = "cudaErrorIllegalAddress";
    case 701:
        msg = "cudaErrorLaunchOutOfResources";
    case 702:
        msg = "cudaErrorLaunchTimeout";
    case 703:
        msg = "cudaErrorLaunchIncompatibleTexturing";
    case 704:
        msg = "cudaErrorPeerAccessAlreadyEnabled";
    case 705:
        msg = "cudaErrorPeerAccessNotEnabled";
    case 708:
        msg = "cudaErrorSetOnActiveProcess";
    case 709:
        msg = "cudaErrorContextIsDestroyed";
    case 710:
        msg = "cudaErrorAssert";
    case 711:
        msg = "cudaErrorTooManyPeers";
    case 712:
        msg = "cudaErrorHostMemoryAlreadyRegistered";
    case 713:
        msg = "cudaErrorHostMemoryNotRegistered";
    case 714:
        msg = "cudaErrorHardwareStackError";
    case 715:
        msg = "cudaErrorIllegalInstruction";
    case 716:
        msg = "cudaErrorMisalignedAddress";
    case 717:
        msg = "cudaErrorInvalidAddressSpace";
    case 718:
        msg = "cudaErrorInvalidPc";
    case 719:
        msg = "cudaErrorLaunchFailure";
    case 720:
        msg = "cudaErrorCooperativeLaunchTooLarge";
    case 800:
        msg = "cudaErrorNotPermitted";
    case 801:
        msg = "cudaErrorNotSupported";
    case 802:
        msg = "cudaErrorSystemNotReady";
    case 803:
        msg = "cudaErrorSystemDriverMismatch";
    case 804:
        msg = "cudaErrorCompatNotSupportedOnDevice";
    case 900:
        msg = "cudaErrorStreamCaptureUnsupported";
    case 901:
        msg = "cudaErrorStreamCaptureInvalidated";
    case 902:
        msg = "cudaErrorStreamCaptureMerge";
    case 903:
        msg = "cudaErrorStreamCaptureUnmatched";
    case 904:
        msg = "cudaErrorStreamCaptureUnjoined";
    case 905:
        msg = "cudaErrorStreamCaptureIsolation";
    case 906:
        msg = "cudaErrorStreamCaptureImplicit";
    case 907:
        msg = "cudaErrorCapturedEvent";
    case 908:
        msg = "cudaErrorStreamCaptureWrongThread";
    case 909:
        msg = "cudaErrorTimeout";
    case 910:
        msg = "cudaErrorGraphExecUpdateFailure";
    case 999:
        msg = "cudaErrorUnknown";
    default:
        msg = "NonValidCudaError";
    }
    return msg;
}

// CURAND error check to get error name
std::string CURAND_CHECK_VAL(curandStatus_t x)
{
    std::string msg;

    switch (x)
    {
    case 0:
        msg = "CURAND_STATUS_SUCCESS";
    case 100:
        msg = "CURAND_STATUS_VERSION_MISMATCH";
    case 101:
        msg = "CURAND_STATUS_NOT_INITIALIZED";
    case 102:
        msg = "CURAND_STATUS_ALLOCATION_FAILED";
    case 103:
        msg = "CURAND_STATUS _Type _ERROR";
    case 104:
        msg = "CURAND_STATUS_OUT_OF_RANGE";
    case 105:
        msg = "CURAND_STATUS_LENGTH_NOT_MULTIPLE";
    case 106:
        msg = "CURAND_STATUS_DOUBLE_PRECISION_REQUIRED";
    case 201:
        msg = "CURAND_STATUS_LAUNCH_FAILURE";
    case 202:
        msg = "CURAND_STATUS_PREEXISTING_FAILURE";
    case 203:
        msg = "CURAND_STATUS_INITIALIZATION_FAILED";
    case 204:
        msg = "CURAND_STATUS_ARCH_MISMATCH";
    case 999:
        msg = "CURAND_STATUS_INTERNAL_ERROR";
    default:
        msg = "NON_VALID_CURAND_ERROR";
    }
    return msg;
}
} // namespace cuda_checks

#endif // KERNEL_IMPL