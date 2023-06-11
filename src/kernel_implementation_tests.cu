#include "kernel_impl.cuh"

#include "types.cuh"

#include <iostream>
#include <map>
#include <optional>
#include <sstream>

namespace test_kernel_implementations
{
namespace test_kernel_implementations_enum
{
enum tests
{
    add_user_space,
    sub_user_space,
    mul_user_space,
    div_user_space,
    generate_random_number_user_space,
    generate_random_number_user_space_with_seed,
    matrix_multiply_user_space,
    matrix_multiply_user_space_with_squished_matrix,
};

std::map<tests, std::string> test_names = {
    {add_user_space, "add_user_space"},
    {sub_user_space, "sub_user_space"},
    {mul_user_space, "mul_user_space"},
    {div_user_space, "div_user_space"},
    {generate_random_number_user_space, "generate_random_number_user_space"},
    {generate_random_number_user_space_with_seed, "generate_random_number_user_space_with_seed"},
    {matrix_multiply_user_space, "matrix_multiply_user_space"},
    {matrix_multiply_user_space_with_squished_matrix, "matrix_multiply_user_space_with_squished_matrix"},
};
} // namespace test_kernel_implementations_enum

class test_kernel_implementation_class
{
  public:
    test_kernel_implementation_class() = default;
    ~test_kernel_implementation_class() = default;

    std::map<test_kernel_implementations_enum::tests, std::optional<std::string>> run()
    {
        test_add_user_space();
        test_sub_user_space();
        test_mul_user_space();
        test_div_user_space();

        test_generate_random_number_user_space();
        test_generate_random_number_user_space_with_seed();

        test_matrix_multiply_user_space();
        test_matrix_multiply_user_space_with_squished_matrix();

        return results;
    }

  private:
    std::map<test_kernel_implementations_enum::tests, std::optional<std::string>> results;

    bool check_1d_array_result(int *expected_result, int *result, int size)
    {
        for (int i = 0; i < size; i++)
        {
            if (expected_result[i] != result[i])
            {
                return false;
            }
        }
        return true;
    }

    template <typename _Type, std::size_t size>
    bool check_1d_array_result(std::array<_Type, size> expected_result, std::array<_Type, size> result)
    {
        for (int i = 0; i < size; i++)
        {
            if (expected_result[i] != result[i])
                return false;
        }
        return true;
    }

    std::string print_1d_array(int *array, int size)
    {
        std::stringstream ss;
        ss << "[";
        for (int i = 0; i < size; i++)
        {
            ss << array[i];
            if (i != size - 1)
            {
                ss << ", ";
            }
        }
        ss << "]";

        return ss.str();
    }

    template <typename _Type, std::size_t size> std::string print_1d_array(std::array<_Type, size> array)
    {
        std::stringstream ss;
        ss << "[";
        for (int i = 0; i < size; i++)
        {
            ss << array[i];
            if (i != size - 1)
            {
                ss << ", ";
            }
        }
        ss << "]";

        return ss.str();
    }

    void test_add_user_space()
    {
        std::array<int, 5> left_array = {1, 2, 3, 4, 5};
        std::array<int, 5> right_array = {1, 2, 3, 4, 5};

        std::array<int, 5> result;
        std::array<int, 5> expected_result = {2, 4, 6, 8, 10};

        std_vec::user_space::add(result, left_array, right_array);

        if (check_1d_array_result(expected_result, result))
            this->results[test_kernel_implementations_enum::tests::add_user_space] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Result of addition between " << print_1d_array(left_array) << " and " << print_1d_array(right_array)
               << " is " << print_1d_array(result) << " but expected " << print_1d_array(expected_result) << std::endl;
            this->results[test_kernel_implementations_enum::tests::add_user_space] = ss.str();
        }
    }
    void test_sub_user_space()
    {
        std::array<int, 5> left_array = {1, 2, 3, 4, 5};
        std::array<int, 5> right_array = {1, 2, 3, 4, 5};

        std::array<int, 5> result;
        std::array<int, 5> expected_result = {0, 0, 0, 0, 0};

        std_vec::user_space::sub(result, left_array, right_array);

        if (check_1d_array_result(expected_result, result))
            this->results[test_kernel_implementations_enum::tests::sub_user_space] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Result of subtraction between " << print_1d_array(left_array) << " and "
               << print_1d_array(right_array) << " is " << print_1d_array(result) << " but expected "
               << print_1d_array(expected_result) << std::endl;
            this->results[test_kernel_implementations_enum::tests::sub_user_space] = ss.str();
        }
    }
    void test_mul_user_space()
    {
        std::array<int, 5> left_array = {1, 2, 3, 4, 5};
        std::array<int, 5> right_array = {1, 2, 3, 4, 5};

        std::array<int, 5> result;
        std::array<int, 5> expected_result = {1, 4, 9, 16, 25};

        std_vec::user_space::mul(result, left_array, right_array);

        if (check_1d_array_result(expected_result, result))
            this->results[test_kernel_implementations_enum::tests::mul_user_space] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Result of addition between " << print_1d_array(left_array) << " and " << print_1d_array(right_array)
               << " is " << print_1d_array(result) << " but expected " << print_1d_array(expected_result) << std::endl;
            this->results[test_kernel_implementations_enum::tests::mul_user_space] = ss.str();
        }
    }
    void test_div_user_space()
    {
        std::array<int, 5> left_array = {1, 2, 3, 4, 5};
        std::array<int, 5> right_array = {1, 2, 3, 4, 5};

        std::array<int, 5> result;
        std::array<int, 5> expected_result = {1, 1, 1, 1, 1};

        std_vec::user_space::div(result, left_array, right_array);

        if (check_1d_array_result(expected_result, result))
            this->results[test_kernel_implementations_enum::tests::div_user_space] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Result of addition between " << print_1d_array(left_array) << " and " << print_1d_array(right_array)
               << " is " << print_1d_array(result) << " but expected " << print_1d_array(expected_result) << std::endl;
            this->results[test_kernel_implementations_enum::tests::div_user_space] = ss.str();
        }
    }

    void test_generate_random_number_user_space()
    {
        std::array<int, 5> first_array = {};
        std::array<int, 5> second_array = {};

        std_vec::user_space::generate_random_number(first_array, 5, 10);
        std_vec::user_space::generate_random_number(second_array, 5, 10);

        if (!check_1d_array_result(first_array, second_array))
            this->results[test_kernel_implementations_enum::tests::div_user_space] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Arrays " << print_1d_array(first_array) << " and " << print_1d_array(second_array)
               << " are the same " << std::endl;
            this->results[test_kernel_implementations_enum::tests::div_user_space] = ss.str();
        }
    }

    void test_generate_random_number_user_space_with_seed()
    {
        // std::cout << "test_generate_random_number_user_space_with_seed" << std::endl;
        std::stringstream ss;
        ss << "test_generate_random_number_user_space_with_seed" << std::endl;
        results[test_kernel_implementations_enum::tests::generate_random_number_user_space_with_seed] = ss.str();
    }

    void test_matrix_multiply_user_space()
    {
        // std::cout << "test_matrix_multiply_user_space" << std::endl;
        std::stringstream ss;
        ss << "test_matrix_multiply_user_space" << std::endl;
        results[test_kernel_implementations_enum::tests::matrix_multiply_user_space] = ss.str();
    }

    void test_matrix_multiply_user_space_with_squished_matrix()
    {
        // std::cout << "test_matrix_multiply_user_space_with_squished_matrix" << std::endl;
        std::stringstream ss;
        ss << "test_matrix_multiply_user_space_with_squished_matrix" << std::endl;
        results[test_kernel_implementations_enum::tests::matrix_multiply_user_space_with_squished_matrix] = ss.str();
    }
};
} // namespace test_kernel_implementations

int main()
{
    test_kernel_implementations::test_kernel_implementation_class test_kernel_implementation;
    auto results = test_kernel_implementation.run();

    for (auto const &result : results)
    {
        if (result.second.has_value())
            std::cout << "\033[31mTest "
                      << test_kernel_implementations::test_kernel_implementations_enum::test_names[result.first]
                      << " failed: " << result.second.value() << "\033[0m" << std::endl;
        else
        {
            std::cout << "\033[32mTest "
                      << test_kernel_implementations::test_kernel_implementations_enum::test_names[result.first]
                      << " passed\033[0m" << std::endl;
        }
    }
}