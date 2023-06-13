#define USE_CUDA

#include "vector_ext.cuh"

#include <iostream>
#include <map>
#include <optional>
#include <sstream>

namespace test_vector_ext_cuda {
    namespace test_vector_ext_cuda_enum {
        enum tests {
            addition_operation,
            subtraction_operation,
            multiplication_operation,
            division_operation,
        };

        std::map<tests, std::string> test_names = {
                {addition_operation, "addition_operation"},
                {subtraction_operation, "subtraction_operation"},
                {multiplication_operation, "multiplication_operation"},
                {division_operation, "division_operation"}
        };
    }

    class test_vector_ext_cuda_class {
    public:
        test_vector_ext_cuda_class() = default;
        ~test_vector_ext_cuda_class() = default;

        std::map<test_vector_ext_cuda_enum::tests, std::optional<std::string>> run()
        {
            test_addition_operator();
            test_subtraction_operator();
            test_multiplication_operator();
            test_division_operator();

            return results;
        }

    private:
        std::map<test_vector_ext_cuda_enum::tests, std::optional<std::string>> results;

        template <typename Type_> std::string print_1d_array(std_vec::vector_ext<Type_> array)
        {
            std::stringstream ss;
            ss << "[";
            std::for_each(array.begin(), array.end(), [&](Type_ i){ ss << i; });
            ss << "]";

            return ss.str();
        }

        void test_addition_operator() {
            std_vec::vector_ext<i32> rh{1, 2, 3, 4};
            std_vec::vector_ext<i32> lh{9, 8, 7, 6};

            std_vec::vector_ext<i32> expected_result{10, 10, 10, 10};
            auto actual_result = rh + lh;

            if (actual_result == expected_result)
                this->results[test_vector_ext_cuda_enum::addition_operation] = std::nullopt;
            else
            {
                std::stringstream ss;
                ss << "Testing " << test_vector_ext_cuda_enum::test_names[test_vector_ext_cuda_enum::addition_operation]
                   << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(actual_result);
                this->results[test_vector_ext_cuda_enum::addition_operation] = ss.str();
            }
        }
        void test_subtraction_operator() {
            std_vec::vector_ext<i32> rh{1, 2, 3, 4};
            std_vec::vector_ext<i32> lh{9, 8, 7, 6};

            std_vec::vector_ext<i32> expected_result{-8, -6, -4, -2};
            auto actual_result = rh - lh;

            if (actual_result == expected_result)
                this->results[test_vector_ext_cuda_enum::subtraction_operation] = std::nullopt;
            else
            {
                std::stringstream ss;
                ss << "Testing " << test_vector_ext_cuda_enum::test_names[test_vector_ext_cuda_enum::subtraction_operation]
                   << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(actual_result);
                this->results[test_vector_ext_cuda_enum::subtraction_operation] = ss.str();
            }
        }
        void test_multiplication_operator() {
            std_vec::vector_ext<i32> rh{1, 2, 3, 4};
            std_vec::vector_ext<i32> lh{9, 8, 7, 6};

            std_vec::vector_ext<i32> expected_result{9, 16, 21, 24};
            auto actual_result = rh * lh;

            if (actual_result == expected_result)
                this->results[test_vector_ext_cuda_enum::multiplication_operation] = std::nullopt;
            else
            {
                std::stringstream ss;
                ss << "Testing " << test_vector_ext_cuda_enum::test_names[test_vector_ext_cuda_enum::multiplication_operation]
                   << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(actual_result);
                this->results[test_vector_ext_cuda_enum::multiplication_operation] = ss.str();
            }
        }
        void test_division_operator() {
            std_vec::vector_ext<f64> rh{1, 2, 3, 4};
            std_vec::vector_ext<f64> lh{9, 8, 7, 6};

            std_vec::vector_ext<f64> expected_result{0.111, 0.25, 0.429, 0.666};
            auto actual_result = rh / lh;

            if (expected_result - actual_result < this->vector_epsilon)
                this->results[test_vector_ext_cuda_enum::multiplication_operation] = std::nullopt;
            else
            {
                std::stringstream ss;
                ss << "Testing " << test_vector_ext_cuda_enum::test_names[test_vector_ext_cuda_enum::multiplication_operation]
                   << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(actual_result);
                this->results[test_vector_ext_cuda_enum::multiplication_operation] = ss.str();
            }
        }

        f64 epsilon = 0.00001;
        std_vec::vector_ext<f64> vector_epsilon{epsilon, epsilon, epsilon, epsilon};
    };
}

int main()
{
    auto test = test_vector_ext_cuda::test_vector_ext_cuda_class();
    std::map<test_vector_ext_cuda::test_vector_ext_cuda_enum::tests, std::optional<std::string>> results = test.run();

    for (auto const &result : results)
    {
        if (result.second.has_value())
            std::cout << "Test " << test_vector_ext_cuda::test_vector_ext_cuda_enum::test_names[result.first]
                      << " failed: " << result.second.value() << std::endl;
        else
        {
            std::cout << "Test " << test_vector_ext_cuda::test_vector_ext_cuda_enum::test_names[result.first] << " passed"
                      << std::endl;
        }
    }
}