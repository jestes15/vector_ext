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

    void test_add_user_space()
    {
        std::cout << "test_add_user_space" << std::endl;
        std::stringstream ss;
        ss << "test_add_user_space" << std::endl;
        results[test_kernel_implementations_enum::tests::add_user_space] = ss.str();
    }

    void test_sub_user_space()
    {
        std::cout << "test_sub_user_space" << std::endl;
        std::stringstream ss;
        ss << "test_sub_user_space" << std::endl;
        results[test_kernel_implementations_enum::tests::sub_user_space] = ss.str();
    }

    void test_mul_user_space()
    {
        std::cout << "test_mul_user_space" << std::endl;
        std::stringstream ss;
        ss << "test_mul_user_space" << std::endl;
        results[test_kernel_implementations_enum::tests::mul_user_space] = ss.str();
    }

    void test_div_user_space()
    {
        std::cout << "test_div_user_space" << std::endl;
        std::stringstream ss;
        ss << "test_div_user_space" << std::endl;
        results[test_kernel_implementations_enum::tests::div_user_space] = ss.str();
    }

    void test_generate_random_number_user_space()
    {
        std::cout << "test_generate_random_number_user_space" << std::endl;
        std::stringstream ss;
        ss << "test_generate_random_number_user_space" << std::endl;
        results[test_kernel_implementations_enum::tests::generate_random_number_user_space] = ss.str();
    }

    void test_generate_random_number_user_space_with_seed()
    {
        std::cout << "test_generate_random_number_user_space_with_seed" << std::endl;
        std::stringstream ss;
        ss << "test_generate_random_number_user_space_with_seed" << std::endl;
        results[test_kernel_implementations_enum::tests::generate_random_number_user_space_with_seed] = ss.str();
    }

    void test_matrix_multiply_user_space()
    {
        std::cout << "test_matrix_multiply_user_space" << std::endl;
        std::stringstream ss;
        ss << "test_matrix_multiply_user_space" << std::endl;
        results[test_kernel_implementations_enum::tests::matrix_multiply_user_space] = ss.str();
    }

    void test_matrix_multiply_user_space_with_squished_matrix()
    {
        std::cout << "test_matrix_multiply_user_space_with_squished_matrix" << std::endl;
        std::stringstream ss;
        ss << "test_matrix_multiply_user_space_with_squished_matrix" << std::endl;
        results[test_kernel_implementations_enum::tests::matrix_multiply_user_space_with_squished_matrix] = ss.str();
    }
};
} // namespace test_kernel_implementations

int main()
{

}