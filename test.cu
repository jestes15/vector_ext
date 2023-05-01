#include "quaternion.cuh"

#include <iostream>

int main()
{
    quaternion q1(1, 2, 3, 4);
    quaternion q2(5, 6, 7, 8);
    quaternion q3 = q1 + q2;

    quaternion q4 = q1 * q2;
    quaternion q5 = 5 * q1;

    std::cout << q1 << " + " << q2 << " = " << q3 << std::endl;
    std::cout << q1 << " * " << q2 << " = " << q4 << std::endl;
    std::cout << 5 << " * " << q1 << " = " << q5 << std::endl;
    return 0;
}