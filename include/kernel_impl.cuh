#pragma once

#include <iostream>

#include "cuda.h"
#include "curand.h"

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

// CUDA return value checks
std::string CUDA_CHECK_VAL(cudaError_t);
std::string CURAND_CHECK_VAL(curandStatus_t);

const int TILE_WIDTH = 32;

// Check method for checking the error status of a CUDA call
#define CUDA_CALL(x)                                                                                           \
    {                                                                                                          \
        if (x != cudaSuccess)                                                                                  \
        {                                                                                                      \
            std::cout << "Error: " << CUDA_CHECK_VAL(x) << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
            return EXIT_FAILURE;                                                                               \
        }                                                                                                      \
    }

// Check method for checking the error status of a cuRAND call
#define CURAND_CALL(x)                                                                                           \
    {                                                                                                            \
        if (x != CURAND_STATUS_SUCCESS)                                                                          \
        {                                                                                                        \
            std::cout << "Error: " << CURAND_CHECK_VAL(x) << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
            return EXIT_FAILURE;                                                                                 \
        }                                                                                                        \
    }

// Implemntation of kernels
namespace kernel
{
    // Kernel for adding two arrays
    template <typename T>
    __global__ void add_kernel(T *dest, T *src_1, T *src_2, unsigned int size)
    {
        int id = blockDim.x * blockIdx.x + threadIdx.x;
        int stride = blockDim.x * gridDim.x;

        for (size_t i = id; i < size; i += stride)
            dest[i] = src_1[i] + src_2[i];
    }

    // Kernel for subtracting two arrays
    template <typename T>
    __global__ void sub_kernel(T *dest, T *src_1, T *src_2, unsigned int size)
    {
        int id = blockDim.x * blockIdx.x + threadIdx.x;
        int stride = blockDim.x * gridDim.x;

        for (size_t i = id; i < size; i += stride)
        {
            dest[i] = src_1[i] - src_2[i];
        }
    }

    // Kernel for multiplying two arrays
    template <typename T>
    __global__ void mul_kernel(T *dest, T *src_1, T *src_2, unsigned int size)
    {
        int id = blockDim.x * blockIdx.x + threadIdx.x;
        int stride = blockDim.x * gridDim.x;

        for (size_t i = id; i < size; i += stride)
        {
            dest[i] = src_1[i] * src_2[i];
        }
    }

    // Kernel for dividing two arrays
    template <typename T>
    __global__ void div_kernel(T *dest, T *src_1, T *src_2, unsigned int size)
    {
        int id = blockDim.x * blockIdx.x + threadIdx.x;
        int stride = blockDim.x * gridDim.x;

        for (size_t i = id; i < size; i += stride)
        {
            dest[i] = src_1[i] / src_2[i];
        }
    }

    // Kernel to bring more digits into the non-floating point space
    template <typename T>
    __global__ void make_float_larger(T *dest, float *device_float_src, unsigned int size, int float_shift)
    {
        int id = blockDim.x * blockIdx.x + threadIdx.x;
        int stride = blockDim.x * gridDim.x;

        for (size_t i = id; i < size; i += stride)
        {
            dest[i] = static_cast<T>(device_float_src[i] * float_shift);
        }
    }

    // Kernel to bring the digits within the max value of the non-floating point space
    template <typename T>
    __global__ void bring_random_below_max(T *dest, unsigned int size, int max)
    {
        int id = blockDim.x * blockIdx.x + threadIdx.x;
        int stride = blockDim.x * gridDim.x;

        for (size_t i = id; i < size; i += stride)
        {
            dest[i] %= max;
        }
    }

    // Kernel to impliment matrix multiplication on nxn matrix
    template <typename T>
    __global__ void matrix_mul(T *dest, T *src_1, T * src_2,
                            int num_dest_rows, int num_dest_columns,
                            int num_src_1_rows, int num_src_1_columns,
                            int num_src_2_rows, int num_src_2_columns)
    {
        T c_value = 0;

        int row = blockDim.y * TILE_WIDTH + threadIdx.y;
        int col = blockDim.x * TILE_WIDTH + threadIdx.x;

        __shared__ T sA[TILE_WIDTH][TILE_WIDTH];
        __shared__ T sB[TILE_WIDTH][TILE_WIDTH];

        for (int ph = 0; ph < (TILE_WIDTH + num_src_1_columns - 1) / TILE_WIDTH; ph++)
        {
            if ((row < num_src_1_rows) && (threadIdx.x + (ph * TILE_WIDTH)) < num_src_1_columns)
                sA[threadIdx.y][threadIdx.x] = src_1[(row * num_src_1_columns) + threadIdx.x + (ph * TILE_WIDTH)];
            else
                sA[threadIdx.y][threadIdx.x] = 0;

            if (col < num_src_2_columns && (threadIdx.y + ph * TILE_WIDTH) < num_src_2_rows)
                sB[threadIdx.y][threadIdx.x] = src_2[(threadIdx.y + ph * TILE_WIDTH) * num_src_2_columns + col];
            else
                sB[threadIdx.y][threadIdx.x] = 0;

            __syncthreads();

            for (int j = 0; j < TILE_WIDTH; ++j)
                c_value += sA[threadIdx.y][j] * sB[j][threadIdx.x];
        }
        if (row < num_dest_rows && col < num_dest_columns)
            dest[((blockIdx.y * blockDim.y + threadIdx.y) * num_dest_columns) + (blockIdx.x * blockDim.x)+ threadIdx.x] = c_value;
    }
}

namespace auxillary {
    template <typename _DestType, typename _SrcType>
    void squish(_DestType* dest, _SrcType** src, std::size_t column, std::size_t row) {
        for (std::size_t i = 0; i < row; i++) {
            for (std::size_t j = 0; j < column; j++) {
                dest[i * column + j] = static_cast<_DestType>(src[i][j]);
            }
        }
    }
}

namespace user_space
{
    // Driver code to handle setting up the device and calling the kernel for addition
    template <typename T>
    int add(T *dest, T *src_1, T *src_2, size_t size_v)
    {
        T *device_src_1, *device_src_2, *device_dest;
        int iLen(1024);

        unsigned long long size = size_v;

        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_1), sizeof(T) * size));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_2), sizeof(T) * size));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_dest), sizeof(T) * size));

        CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(T) * size, cudaMemcpyHostToDevice));
        CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(T) * size, cudaMemcpyHostToDevice));

        dim3 block(iLen);
        dim3 grid((size + block.x - 1) / block.x);

        kernel::add_kernel<<<grid, block>>>(device_dest, device_src_1, device_src_2, size);

        CUDA_CALL(cudaDeviceSynchronize());

        CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(T) * size, cudaMemcpyDeviceToHost));

        CUDA_CALL(cudaFree(device_src_1));
        CUDA_CALL(cudaFree(device_src_2));
        CUDA_CALL(cudaFree(device_dest));

        return EXIT_SUCCESS;
    }

    // Driver code to handle setting up the device and calling the kernel for subtraction
    template <typename T>
    int sub(T *dest, T *src_1, T *src_2, unsigned int size)
    {
        T *device_src_1, *device_src_2, *device_dest;
        int iLen(1024);

        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_1), sizeof(T) * size));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_2), sizeof(T) * size));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_dest), sizeof(T) * size));

        CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(T) * size, cudaMemcpyHostToDevice));
        CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(T) * size, cudaMemcpyHostToDevice));

        dim3 block(iLen);
        dim3 grid((size + block.x - 1) / block.x);

        kernel::sub_kernel<<<grid, block>>>(device_dest, device_src_1, device_src_2, size);

        CUDA_CALL(cudaDeviceSynchronize());

        CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(T) * size, cudaMemcpyDeviceToHost));

        CUDA_CALL(cudaFree(device_src_1));
        CUDA_CALL(cudaFree(device_src_2));
        CUDA_CALL(cudaFree(device_dest));

        return EXIT_SUCCESS;
    }

    // Driver code to handle setting up the device and calling the kernel for multiplication
    template <typename T>
    int mul(T *dest, T *src_1, T *src_2, unsigned int size)
    {
        T *device_src_1, *device_src_2, *device_dest;
        int iLen(1024);

        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_1), sizeof(T) * size));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_2), sizeof(T) * size));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_dest), sizeof(T) * size));

        CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(T) * size, cudaMemcpyHostToDevice));
        CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(T) * size, cudaMemcpyHostToDevice));

        dim3 block(iLen);
        dim3 grid((size + block.x - 1) / block.x);

        kernel::mul_kernel<<<grid, block>>>(device_dest, device_src_1, device_src_2, size);

        CUDA_CALL(cudaDeviceSynchronize());

        CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(T) * size, cudaMemcpyDeviceToHost));

        CUDA_CALL(cudaFree(device_src_1));
        CUDA_CALL(cudaFree(device_src_2));
        CUDA_CALL(cudaFree(device_dest));

        return EXIT_SUCCESS;
    }

    // Driver code to handle setting up the device and calling the kernel for division
    template <typename T>
    int div(T *dest, T *src_1, T *src_2, unsigned int size)
    {
        T *device_src_1, *device_src_2, *device_dest;
        int iLen(1024);

        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_1), sizeof(T) * size));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_2), sizeof(T) * size));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_dest), sizeof(T) * size));

        CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(T) * size, cudaMemcpyHostToDevice));
        CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(T) * size, cudaMemcpyHostToDevice));

        dim3 block(iLen);
        dim3 grid((size + block.x - 1) / block.x);

        kernel::div_kernel<<<grid, block>>>(device_dest, device_src_1, device_src_2, size);

        CUDA_CALL(cudaDeviceSynchronize());

        CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(T) * size, cudaMemcpyDeviceToHost));

        CUDA_CALL(cudaFree(device_src_1));
        CUDA_CALL(cudaFree(device_src_2));
        CUDA_CALL(cudaFree(device_dest));

        return EXIT_SUCCESS;
    }

    // Driver code to handle setting up the device and calling the kernel for geberating random numbers
    template <typename T>
    int generate_random_number(T *dest, unsigned int size, int float_shift, int max)
    {
        float *random_number_gen_dest;
        T *device_dest_int;
        int iLen(1024);

        curandGenerator_t gen;
        dim3 block(iLen);
        dim3 grid((size + block.x - 1) / block.x);

        CUDA_CALL(cudaMalloc(reinterpret_cast<float **>(&random_number_gen_dest), sizeof(float) * size))
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_dest_int), sizeof(T) * size))

        CURAND_CALL(curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT))
        CURAND_CALL(curandSetPseudoRandomGeneratorSeed(gen, time(NULL)))
        CURAND_CALL(curandGenerateUniform(gen, random_number_gen_dest, size))

        kernel::make_float_larger<<<grid, block>>>(device_dest_int, random_number_gen_dest, size, float_shift);
        kernel::bring_random_below_max<<<grid, block>>>(device_dest_int, size, max);

        CUDA_CALL(cudaDeviceSynchronize())

        CUDA_CALL(cudaMemcpy(dest, device_dest_int, sizeof(T) * size, cudaMemcpyDeviceToHost))

        CUDA_CALL(cudaFree(random_number_gen_dest))
        CUDA_CALL(cudaFree(device_dest_int))

        return EXIT_SUCCESS;
    }

    template <typename T>
    int generate_random_number(T *dest, unsigned int size, int float_shift, int max, int seed)
    {
        float *random_number_gen_dest;
        T *device_dest_int;
        int iLen(1024);

        curandGenerator_t gen;
        dim3 block(iLen);
        dim3 grid((size + block.x - 1) / block.x);

        CUDA_CALL(cudaMalloc(reinterpret_cast<float **>(&random_number_gen_dest), sizeof(float) * size))
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_dest_int), sizeof(T) * size))

        CURAND_CALL(curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT))
        CURAND_CALL(curandSetPseudoRandomGeneratorSeed(gen, seed))
        CURAND_CALL(curandGenerateUniform(gen, random_number_gen_dest, size))

        kernel::make_float_larger<<<grid, block>>>(device_dest_int, random_number_gen_dest, size, float_shift);
        kernel::bring_random_below_max<<<grid, block>>>(device_dest_int, size, max);

        CUDA_CALL(cudaDeviceSynchronize())

        CUDA_CALL(cudaMemcpy(dest, device_dest_int, sizeof(T) * size, cudaMemcpyDeviceToHost))

        CUDA_CALL(cudaFree(random_number_gen_dest))
        CUDA_CALL(cudaFree(device_dest_int))

        return EXIT_SUCCESS;
    }

    // Driver code to handle setting up the device and calling the kernel for matrix multiplication
    template <typename T>
    int matrix_mul(T *dest, T *src_1, T *src_2, unsigned int rows_src_1, unsigned int columns_src_1, unsigned int rows_src_2, unsigned int columns_src_2)
    {
        T *device_src_1, *device_src_2, *device_dest;

        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_1), sizeof(T) * rows_src_1 * columns_src_1));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_src_2), sizeof(T) * rows_src_2 * columns_src_2));
        CUDA_CALL(cudaMalloc(reinterpret_cast<T **>(&device_dest), sizeof(T) * rows_src_1 * columns_src_2));

        CUDA_CALL(cudaMemcpy(device_src_1, src_1, sizeof(T) * rows_src_1 * columns_src_1, cudaMemcpyHostToDevice));
        CUDA_CALL(cudaMemcpy(device_src_2, src_2, sizeof(T) * rows_src_2 * columns_src_2, cudaMemcpyHostToDevice));

        dim3 dimBlock(TILE_WIDTH, TILE_WIDTH, 1);
        dim3 dimGrid;

        dimGrid.x = (columns_src_2 + dimBlock.x - 1) / dimBlock.x;
        dimGrid.y = (rows_src_1 + dimBlock.y - 1) / dimBlock.y;

        kernel::matrix_mul<<<dimGrid, dimBlock>>>(device_dest, device_src_1, device_src_2, rows_src_1, columns_src_2, rows_src_1, columns_src_1, rows_src_2, columns_src_2);

        CUDA_CALL(cudaDeviceSynchronize());

        CUDA_CALL(cudaMemcpy(dest, device_dest, sizeof(T) * rows_src_1 * columns_src_2, cudaMemcpyDeviceToHost));

        CUDA_CALL(cudaFree(device_src_1));
        CUDA_CALL(cudaFree(device_src_2));
        CUDA_CALL(cudaFree(device_dest));

        return EXIT_SUCCESS;
    }
}

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
        msg = "CURAND_STATUS_TYPE_ERROR";
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
