#include "simd_vector_operations.hpp"

#include <arm_neon.h>
#include <stdio.h>

unsigned char B[] = {1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8};
unsigned char C[] = {1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8};

int main(void)
{
    unsigned char A[16];
    simd::vec_add_u8x16(A, B, C);

    for (int i = 0; i < 16; i++)
    {
        printf("%d ", A[i]);
    }

    return 0;
}
