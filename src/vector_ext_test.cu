#include "vector_ext.cuh"

#include <iostream>
#include <map>
#include <optional>
#include <sstream>

namespace test_vector_ext
{
namespace test_vector_ext_enum
{
enum tests
{
    at_operation_positive_index,
    at_operation_negative_index,
    addition_operation,
    subtraction_operation,
    multiplication_operation,
    division_operation,
    pre_increment_operator,
    post_increment_operator,
    pre_decrement_operator,
    post_decrement_operator,
    quick_sort_with_compare,
    quick_sort_without_compare,
    merge_sort_with_compare,
    merge_sort_without_compare,
    insertion_sort_with_compare,
    insertion_sort_without_compare,
    sort_with_compare_vector_length_less_than_16,
    sort_with_compare_vector_depth_limit_is_zero,
    sort_with_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero,
    sort_without_compare_vector_length_less_than_16,
    sort_without_compare_vector_depth_limit_is_zero,
    sort_without_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero
};

std::map<tests, std::string> test_names = {
    {at_operation_positive_index, "at_operation_positive_index"},
    {at_operation_negative_index, "at_operation_negative_index"},
    {addition_operation, "addition_operation"},
    {subtraction_operation, "subtraction_operation"},
    {multiplication_operation, "multiplication_operation"},
    {division_operation, "division_operation"},
    {pre_increment_operator, "pre_increment_operator"},
    {post_increment_operator, "post_increment_operator"},
    {pre_decrement_operator, "pre_decrement_operator"},
    {post_decrement_operator, "post_decrement_operator"},
    {quick_sort_with_compare, "quick_sort_with_compare"},
    {quick_sort_without_compare, "quick_sort_without_compare"},
    {merge_sort_with_compare, "merge_sort_with_compare"},
    {merge_sort_without_compare, "merge_sort_without_compare"},
    {insertion_sort_with_compare, "insertion_sort_with_compare"},
    {insertion_sort_without_compare, "insertion_sort_without_compare"},
    {sort_with_compare_vector_length_less_than_16, "sort_with_compare_vector_length_less_than_16"},
    {sort_with_compare_vector_depth_limit_is_zero, "sort_with_compare_vector_depth_limit_is_zero"},
    {sort_with_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero,
     "sort_with_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero"},
    {sort_without_compare_vector_length_less_than_16, "sort_without_compare_vector_length_less_than_16"},
    {sort_without_compare_vector_depth_limit_is_zero, "sort_without_compare_vector_depth_limit_is_zero"},
    {sort_without_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero,
     "sort_without_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero"},
};
} // namespace test_vector_ext_enum

class test_vector_ext_class
{
  public:
    test_vector_ext_class() = default;
    ~test_vector_ext_class() = default;

    std::map<test_vector_ext_enum::tests, std::optional<std::string>> run()
    {
        test_at_operation_positive_index();
        test_at_operation_negative_index();

        test_addition_operator();
        test_subtraction_operator();
        test_multiplication_operator();
        test_division_operator();

        test_pre_increment_operator();
        test_post_increment_operator();
        test_pre_decrement_operator();
        test_post_decrement_operator();

        test_quick_sort_with_compare();
        test_quick_sort_without_compare();

        test_merge_sort_with_compare();
        test_merge_sort_without_compare();

        test_insertion_sort_with_compare();
        test_insertion_sort_without_compare();

        test_sort_with_compare_vector_length_less_than_16();
        // test_sort_with_compare_vector_depth_limit_is_zero();
        test_sort_with_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero();
        test_sort_without_compare_vector_length_less_than_16();
        test_sort_without_compare_vector_depth_limit_is_zero();
        test_sort_without_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero();

        return results;
    }

  private:
    std::map<test_vector_ext_enum::tests, std::optional<std::string>> results;

    template <typename Type_> std::string print_1d_array(std_vec::vector_ext<Type_> array)
    {
        std::stringstream ss;
        ss << "[";
        std::for_each(array.begin(), array.end(), [&](Type_ i) {
            if (i != array.at(array.size() - 1))
            {
                ss << i << " ";
            }
            else
                ss << i;
        });
        ss << "]";

        return ss.str();
    }

    void test_at_operation_positive_index()
    {
        std_vec::vector_ext<i32> rh = {1, 2, 3, 4};
        auto expected_result = 3;

        if (rh.at(2) == expected_result)
            this->results[test_vector_ext_enum::at_operation_positive_index] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::at_operation_positive_index]
               << " failed. Expected: " << expected_result << " Got: " << rh.at(2);
            this->results[test_vector_ext_enum::at_operation_positive_index] = ss.str();
        }
    }
    void test_at_operation_negative_index()
    {
        std_vec::vector_ext<i32> rh = {1, 2, 3, 4};
        auto expected_result = 2;

        if (rh.at(-3) == expected_result)
            this->results[test_vector_ext_enum::at_operation_negative_index] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::at_operation_negative_index]
               << " failed. Expected: " << expected_result << " Got: " << rh.at(2);
            this->results[test_vector_ext_enum::at_operation_negative_index] = ss.str();
        }
    }
    void test_addition_operator()
    {
        std_vec::vector_ext<i32> rh{1, 2, 3, 4};
        std_vec::vector_ext<i32> lh{9, 8, 7, 6};

        std_vec::vector_ext<i32> expected_result{10, 10, 10, 10};
        auto actual_result = rh + lh;

        if (actual_result == expected_result)
            this->results[test_vector_ext_enum::addition_operation] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::addition_operation]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(actual_result);
            this->results[test_vector_ext_enum::addition_operation] = ss.str();
        }
    }
    void test_subtraction_operator()
    {
        std_vec::vector_ext<i32> rh{1, 2, 3, 4};
        std_vec::vector_ext<i32> lh{9, 8, 7, 6};

        std_vec::vector_ext<i32> expected_result{-8, -6, -4, -2};
        auto actual_result = rh - lh;

        if (actual_result == expected_result)
            this->results[test_vector_ext_enum::subtraction_operation] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::subtraction_operation]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(actual_result);
            this->results[test_vector_ext_enum::subtraction_operation] = ss.str();
        }
    }
    void test_multiplication_operator()
    {
        std_vec::vector_ext<i32> rh{1, 2, 3, 4};
        std_vec::vector_ext<i32> lh{9, 8, 7, 6};

        std_vec::vector_ext<i32> expected_result{9, 16, 21, 24};
        auto actual_result = rh * lh;

        if (actual_result == expected_result)
            this->results[test_vector_ext_enum::multiplication_operation] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::multiplication_operation]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(actual_result);
            this->results[test_vector_ext_enum::multiplication_operation] = ss.str();
        }
    }
    void test_division_operator()
    {
        std_vec::vector_ext<f64> rh{1, 2, 3, 4};
        std_vec::vector_ext<f64> lh{9, 8, 7, 6};

        std_vec::vector_ext<f64> expected_result{0.111, 0.25, 0.429, 0.666};
        auto actual_result = rh / lh;

        if (expected_result - actual_result < this->vector_epsilon)
            this->results[test_vector_ext_enum::multiplication_operation] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::multiplication_operation]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(actual_result);
            this->results[test_vector_ext_enum::multiplication_operation] = ss.str();
        }
    }

    void test_pre_increment_operator()
    {
        std_vec::vector_ext<i64> original = {1, 2, 3};

        std_vec::vector_ext<i64> expected_result = {0, 1, 2, 3};

        ++original;

        if (expected_result == original)
            this->results[test_vector_ext_enum::pre_increment_operator] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::pre_increment_operator]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::pre_increment_operator] = ss.str();
        }
    }
    void test_post_increment_operator()
    {
        std_vec::vector_ext<i64> original = {1, 2, 3};

        std_vec::vector_ext<i64> expected_result = {1, 2, 3, 0};

        original++;

        if (expected_result == original)
            this->results[test_vector_ext_enum::post_increment_operator] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::post_increment_operator]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::post_increment_operator] = ss.str();
        }
    }
    void test_pre_decrement_operator()
    {
        std_vec::vector_ext<i64> original = {1, 2, 3};

        std_vec::vector_ext<i64> expected_result = {2, 3};
        auto expected_return_value = 1;

        auto ret = --original;

        if (expected_result == original and ret == expected_return_value)
            this->results[test_vector_ext_enum::pre_decrement_operator] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::pre_decrement_operator]
               << " failed. Expected: " << print_1d_array(expected_result) << ", " << expected_return_value
               << " Got: " << print_1d_array(original) << ", " << ret;
            this->results[test_vector_ext_enum::pre_decrement_operator] = ss.str();
        }
    }
    void test_post_decrement_operator()
    {
        std_vec::vector_ext<i64> original = {1, 2, 3};

        std_vec::vector_ext<i64> expected_result = {1, 2};
        auto expected_return_value = 3;

        auto ret = original--;

        if (expected_result == original and ret == expected_return_value)
            this->results[test_vector_ext_enum::post_decrement_operator] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::post_decrement_operator]
               << " failed. Expected: " << print_1d_array(expected_result) << ", " << expected_return_value
               << " Got: " << print_1d_array(original) << ", " << ret;
            this->results[test_vector_ext_enum::post_decrement_operator] = ss.str();
        }
    }

    void test_quick_sort_with_compare()
    {
        std_vec::vector_ext<i32> original = {9, 2, 5, 1};
        std_vec::vector_ext<i32> expected_result = {9, 5, 2, 1};

        original.quick_sort(std::greater<>());

        if (expected_result == original)
            this->results[test_vector_ext_enum::quick_sort_with_compare] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::quick_sort_with_compare]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::quick_sort_with_compare] = ss.str();
        }
    }
    void test_quick_sort_without_compare()
    {
        std_vec::vector_ext<i32> original = {9, 2, 5, 1};
        std_vec::vector_ext<i32> expected_result = {1, 2, 5, 9};

        original.quick_sort();

        if (expected_result == original)
            this->results[test_vector_ext_enum::quick_sort_without_compare] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::quick_sort_without_compare]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::quick_sort_without_compare] = ss.str();
        }
    }

    void test_merge_sort_with_compare()
    {
        std_vec::vector_ext<i32> original = {9, 2, 5, 1};
        std_vec::vector_ext<i32> expected_result = {9, 5, 2, 1};

        original.merge_sort(std::greater<>());

        if (expected_result == original)
            this->results[test_vector_ext_enum::merge_sort_with_compare] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::merge_sort_with_compare]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::merge_sort_with_compare] = ss.str();
        }
    }
    void test_merge_sort_without_compare()
    {
        std_vec::vector_ext<i32> original = {9, 2, 5, 1};
        std_vec::vector_ext<i32> expected_result = {1, 2, 5, 9};

        original.merge_sort();

        if (expected_result == original)
            this->results[test_vector_ext_enum::merge_sort_without_compare] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::merge_sort_without_compare]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::merge_sort_without_compare] = ss.str();
        }
    }

    void test_insertion_sort_with_compare()
    {
        std_vec::vector_ext<i32> original = {9, 2, 5, 1};
        std_vec::vector_ext<i32> expected_result = {9, 5, 2, 1};

        original.merge_sort(std::greater<>());

        if (expected_result == original)
            this->results[test_vector_ext_enum::insertion_sort_with_compare] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::insertion_sort_with_compare]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::insertion_sort_with_compare] = ss.str();
        }
    }
    void test_insertion_sort_without_compare()
    {
        std_vec::vector_ext<i32> original = {9, 2, 5, 1};
        std_vec::vector_ext<i32> expected_result = {1, 2, 5, 9};

        original.merge_sort();

        if (expected_result == original)
            this->results[test_vector_ext_enum::insertion_sort_without_compare] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_vector_ext_enum::test_names[test_vector_ext_enum::insertion_sort_without_compare]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::insertion_sort_without_compare] = ss.str();
        }
    }

    void test_sort_with_compare_vector_length_less_than_16()
    {
        std_vec::vector_ext<i32> original = {9};
        std_vec::vector_ext<i32> expected_result = {9};

        original.sort(std::greater<>());

        if (expected_result == original)
            this->results[test_vector_ext_enum::sort_with_compare_vector_length_less_than_16] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing "
               << test_vector_ext_enum::test_names[test_vector_ext_enum::sort_with_compare_vector_length_less_than_16]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::sort_with_compare_vector_length_less_than_16] = ss.str();
        }
    }
    /*
    void test_sort_with_compare_vector_depth_limit_is_zero() {
        std_vec::vector_ext<i32> original = {55, 92, 22, 35, 55, 40, 48, 91, 98, 60, 4, 99, 33, 18, 90, 14, 69, 64, 62,
    67}; std_vec::vector_ext<i32> expected_result = {9};

        original.sort();

        if (expected_result == original)
            this->results[test_vector_ext_enum::sort_without_compare_vector_length_less_than_16] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " <<
    test_vector_ext_enum::test_names[test_vector_ext_enum::sort_without_compare_vector_length_less_than_16]
               << " failed. Expected: " << print_1d_array(expected_result)
               << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::sort_without_compare_vector_length_less_than_16] = ss.str();
        }
    }
    */
    void test_sort_with_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero()
    {
    }
    void test_sort_without_compare_vector_length_less_than_16()
    {
    }
    void test_sort_without_compare_vector_depth_limit_is_zero()
    {
    }
    void test_sort_without_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero()
    {
    }

    f64 epsilon = 0.00001;
    std_vec::vector_ext<f64> vector_epsilon{epsilon, epsilon, epsilon, epsilon};
};
} // namespace test_vector_ext

int main()
{
    auto test = test_vector_ext::test_vector_ext_class();
    std::map<test_vector_ext::test_vector_ext_enum::tests, std::optional<std::string>> results = test.run();

    for (auto const &result : results)
    {
        if (result.second.has_value())
            std::cout << "Test " << test_vector_ext::test_vector_ext_enum::test_names[result.first]
                      << " failed: " << result.second.value() << std::endl;
        else
        {
            std::cout << "Test " << test_vector_ext::test_vector_ext_enum::test_names[result.first] << " passed"
                      << std::endl;
        }
    }
}