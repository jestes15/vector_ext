#include "vector_ext.cuh"

#include <iostream>
#include <map>
#include <optional>
#include <sstream>

#include "text_formatting.cuh"

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
        test_sort_with_compare_vector_depth_limit_is_zero();
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
        std::for_each(array.begin(), array.end(), [&](Type_ i) { ss << i << " "; });
        ss << "\b]";

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

        original.sort(std::greater<i32>());

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
    void test_sort_with_compare_vector_depth_limit_is_zero()
    {
        std_vec::vector_ext<i32> original = {
            8,  84, 28, 89, 28, 30, 13, 67,  77, 55, 34, 75, 16, 31,  14, 43,  76, 8,  99, 59, 96, 29, 49, 54, 87,
            57, 17, 23, 9,  42, 62, 83, 100, 52, 80, 15, 61, 60, 46,  67, 24,  24, 57, 68, 30, 19, 16, 35, 37, 60,
            21, 34, 1,  95, 26, 62, 96, 24,  6,  14, 21, 79, 97, 10,  66, 100, 78, 8,  18, 87, 50, 0,  29, 23, 89,
            74, 42, 60, 70, 95, 72, 38, 39,  1,  27, 87, 54, 51, 17,  76, 94,  83, 77, 89, 93, 47, 76, 2,  96, 83,
            22, 81, 57, 47, 90, 41, 65, 92,  70, 52, 31, 93, 1,  100, 60, 22,  30, 95, 19, 81, 58, 0,  60, 58, 3,
            6,  9,  99, 23, 13, 52, 62, 8,   21, 32, 93, 43, 42, 21,  53, 51,  73, 44, 21, 98, 40, 61, 93, 39, 76,
            53, 64, 39, 4,  34, 65, 10, 29,  51, 95, 77, 46, 65, 81,  8,  99,  14, 24, 4,  91, 76, 20, 10, 40, 43,
            82, 25, 64, 28, 79, 5,  18, 60,  83, 43, 46, 89, 88, 35,  78, 26,  19, 68, 12, 85, 85, 71, 78, 20, 75,
            85, 33, 44, 56, 56, 4,  92, 77,  81, 2,  92, 32, 95, 30,  96, 89,  31, 63, 52, 0,  23, 15, 96, 98, 5,
            79, 34, 92, 82, 25, 54, 60, 77,  46, 43, 79, 10, 37, 72,  40, 86,  76, 63, 41, 12, 7,  10, 56, 79, 63,
            9,  50, 88, 71, 97, 36, 92, 16,  82, 14, 92, 3,  27, 5,   82, 74,  27, 37, 76, 11, 19, 40, 10, 45, 41,
            30, 64, 93, 6,  2,  2,  6,  46,  69, 18, 81, 25, 53, 2,   22, 93,  31, 66, 91, 83, 68, 88, 46, 76, 22,
            4,  12, 47, 55, 69, 81, 21, 43,  21, 70, 32, 21, 12, 86,  20, 4,   45, 85, 15, 58, 42, 60, 44, 98, 65,
            10, 18, 42, 29, 24, 65, 59, 76,  8,  72, 78, 75, 96, 91,  58, 25,  96, 72, 81, 92, 11, 80, 18, 39, 42,
            86, 88, 64, 98, 20, 69, 56, 54,  10, 41, 7,  74, 89, 55,  16, 17,  91, 95, 46, 46, 8,  2,  57, 74, 22,
            74, 57, 83, 83, 11, 37, 90, 58,  39, 98, 76, 54, 32, 17,  61, 35,  37, 65, 63, 8,  2,  99, 50, 6,  75};

        std_vec::vector_ext<i32> expected_result = {
            8,  84, 28, 89, 28, 30, 13, 67,  77, 55, 34, 75, 16, 31,  14, 43,  76, 8,  99, 59, 96, 29, 49, 54, 87,
            57, 17, 23, 9,  42, 62, 83, 100, 52, 80, 15, 61, 60, 46,  67, 24,  24, 57, 68, 30, 19, 16, 35, 37, 60,
            21, 34, 1,  95, 26, 62, 96, 24,  6,  14, 21, 79, 97, 10,  66, 100, 78, 8,  18, 87, 50, 0,  29, 23, 89,
            74, 42, 60, 70, 95, 72, 38, 39,  1,  27, 87, 54, 51, 17,  76, 94,  83, 77, 89, 93, 47, 76, 2,  96, 83,
            22, 81, 57, 47, 90, 41, 65, 92,  70, 52, 31, 93, 1,  100, 60, 22,  30, 95, 19, 81, 58, 0,  60, 58, 3,
            6,  9,  99, 23, 13, 52, 62, 8,   21, 32, 93, 43, 42, 21,  53, 51,  73, 44, 21, 98, 40, 61, 93, 39, 76,
            53, 64, 39, 4,  34, 65, 10, 29,  51, 95, 77, 46, 65, 81,  8,  99,  14, 24, 4,  91, 76, 20, 10, 40, 43,
            82, 25, 64, 28, 79, 5,  18, 60,  83, 43, 46, 89, 88, 35,  78, 26,  19, 68, 12, 85, 85, 71, 78, 20, 75,
            85, 33, 44, 56, 56, 4,  92, 77,  81, 2,  92, 32, 95, 30,  96, 89,  31, 63, 52, 0,  23, 15, 96, 98, 5,
            79, 34, 92, 82, 25, 54, 60, 77,  46, 43, 79, 10, 37, 72,  40, 86,  76, 63, 41, 12, 7,  10, 56, 79, 63,
            9,  50, 88, 71, 97, 36, 92, 16,  82, 14, 92, 3,  27, 5,   82, 74,  27, 37, 76, 11, 19, 40, 10, 45, 41,
            30, 64, 93, 6,  2,  2,  6,  46,  69, 18, 81, 25, 53, 2,   22, 93,  31, 66, 91, 83, 68, 88, 46, 76, 22,
            4,  12, 47, 55, 69, 81, 21, 43,  21, 70, 32, 21, 12, 86,  20, 4,   45, 85, 15, 58, 42, 60, 44, 98, 65,
            10, 18, 42, 29, 24, 65, 59, 76,  8,  72, 78, 75, 96, 91,  58, 25,  96, 72, 81, 92, 11, 80, 18, 39, 42,
            86, 88, 64, 98, 20, 69, 56, 54,  10, 41, 7,  74, 89, 55,  16, 17,  91, 95, 46, 46, 8,  2,  57, 74, 22,
            74, 57, 83, 83, 11, 37, 90, 58,  39, 98, 76, 54, 32, 17,  61, 35,  37, 65, 63, 8,  2,  99, 50, 6,  75};

        std::sort(expected_result.begin(), expected_result.end(), std::greater<i32>());

        original.sort(std::greater<i32>());

        if (expected_result == original)
            this->results[test_vector_ext_enum::sort_with_compare_vector_depth_limit_is_zero] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing "
               << test_vector_ext_enum::test_names[test_vector_ext_enum::sort_with_compare_vector_depth_limit_is_zero]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::sort_with_compare_vector_depth_limit_is_zero] = ss.str();
        }
    }
    void test_sort_with_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero()
    {
        std_vec::vector_ext<i32> original = {
            8,  84, 28, 89, 28, 30, 13, 67,  77, 55, 34, 75, 16, 31,  14, 43,  76, 8,  99, 59, 96, 29, 49, 54, 87,
            57, 17, 23, 9,  42, 62, 83, 100, 52, 80, 15, 61, 60, 46,  67, 24,  24, 57, 68, 30, 19, 16, 35, 37, 60,
            21, 34, 1,  95, 26, 62, 96, 24,  6,  14, 21, 79, 97, 10,  66, 100, 78, 8,  18, 87, 50, 0,  29, 23, 89,
            74, 42, 60, 70, 95, 72, 38, 39,  1,  27, 87, 54, 51, 17,  76, 94,  83, 77, 89, 93, 47, 76, 2,  96, 83,
            22, 81, 57, 47, 90, 41, 65, 92,  70, 52, 31, 93, 1,  100, 60, 22,  30, 95, 19, 81, 58, 0,  60, 58, 3,
            6,  9,  99, 23, 13, 52, 62, 8,   21, 32, 93, 43, 42, 21,  53, 51,  73, 44, 21, 98, 40, 61, 93, 39, 76};

        std_vec::vector_ext<i32> expected_result = {
            8,  84, 28, 89, 28, 30, 13, 67,  77, 55, 34, 75, 16, 31,  14, 43,  76, 8,  99, 59, 96, 29, 49, 54, 87,
            57, 17, 23, 9,  42, 62, 83, 100, 52, 80, 15, 61, 60, 46,  67, 24,  24, 57, 68, 30, 19, 16, 35, 37, 60,
            21, 34, 1,  95, 26, 62, 96, 24,  6,  14, 21, 79, 97, 10,  66, 100, 78, 8,  18, 87, 50, 0,  29, 23, 89,
            74, 42, 60, 70, 95, 72, 38, 39,  1,  27, 87, 54, 51, 17,  76, 94,  83, 77, 89, 93, 47, 76, 2,  96, 83,
            22, 81, 57, 47, 90, 41, 65, 92,  70, 52, 31, 93, 1,  100, 60, 22,  30, 95, 19, 81, 58, 0,  60, 58, 3,
            6,  9,  99, 23, 13, 52, 62, 8,   21, 32, 93, 43, 42, 21,  53, 51,  73, 44, 21, 98, 40, 61, 93, 39, 76};

        std::sort(expected_result.begin(), expected_result.end(), std::greater<i32>());

        original.sort(std::greater<i32>());

        if (expected_result == original)
            this->results[test_vector_ext_enum::
                              sort_with_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero] =
                std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing "
               << test_vector_ext_enum::test_names
                      [test_vector_ext_enum::
                           sort_with_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::
                              sort_with_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero] =
                ss.str();
        }
    }

    void test_sort_without_compare_vector_length_less_than_16()
    {
        std_vec::vector_ext<i32> original = {9};
        std_vec::vector_ext<i32> expected_result = {9};

        original.sort();

        if (expected_result == original)
            this->results[test_vector_ext_enum::sort_without_compare_vector_length_less_than_16] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing "
               << test_vector_ext_enum::test_names
                      [test_vector_ext_enum::sort_without_compare_vector_length_less_than_16]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::sort_without_compare_vector_length_less_than_16] = ss.str();
        }
    }
    void test_sort_without_compare_vector_depth_limit_is_zero()
    {
        std_vec::vector_ext<i32> original = {
            8,  84, 28, 89, 28, 30, 13, 67,  77, 55, 34, 75, 16, 31,  14, 43,  76, 8,  99, 59, 96, 29, 49, 54, 87,
            57, 17, 23, 9,  42, 62, 83, 100, 52, 80, 15, 61, 60, 46,  67, 24,  24, 57, 68, 30, 19, 16, 35, 37, 60,
            21, 34, 1,  95, 26, 62, 96, 24,  6,  14, 21, 79, 97, 10,  66, 100, 78, 8,  18, 87, 50, 0,  29, 23, 89,
            74, 42, 60, 70, 95, 72, 38, 39,  1,  27, 87, 54, 51, 17,  76, 94,  83, 77, 89, 93, 47, 76, 2,  96, 83,
            22, 81, 57, 47, 90, 41, 65, 92,  70, 52, 31, 93, 1,  100, 60, 22,  30, 95, 19, 81, 58, 0,  60, 58, 3,
            6,  9,  99, 23, 13, 52, 62, 8,   21, 32, 93, 43, 42, 21,  53, 51,  73, 44, 21, 98, 40, 61, 93, 39, 76,
            53, 64, 39, 4,  34, 65, 10, 29,  51, 95, 77, 46, 65, 81,  8,  99,  14, 24, 4,  91, 76, 20, 10, 40, 43,
            82, 25, 64, 28, 79, 5,  18, 60,  83, 43, 46, 89, 88, 35,  78, 26,  19, 68, 12, 85, 85, 71, 78, 20, 75,
            85, 33, 44, 56, 56, 4,  92, 77,  81, 2,  92, 32, 95, 30,  96, 89,  31, 63, 52, 0,  23, 15, 96, 98, 5,
            79, 34, 92, 82, 25, 54, 60, 77,  46, 43, 79, 10, 37, 72,  40, 86,  76, 63, 41, 12, 7,  10, 56, 79, 63,
            9,  50, 88, 71, 97, 36, 92, 16,  82, 14, 92, 3,  27, 5,   82, 74,  27, 37, 76, 11, 19, 40, 10, 45, 41,
            30, 64, 93, 6,  2,  2,  6,  46,  69, 18, 81, 25, 53, 2,   22, 93,  31, 66, 91, 83, 68, 88, 46, 76, 22,
            4,  12, 47, 55, 69, 81, 21, 43,  21, 70, 32, 21, 12, 86,  20, 4,   45, 85, 15, 58, 42, 60, 44, 98, 65,
            10, 18, 42, 29, 24, 65, 59, 76,  8,  72, 78, 75, 96, 91,  58, 25,  96, 72, 81, 92, 11, 80, 18, 39, 42,
            86, 88, 64, 98, 20, 69, 56, 54,  10, 41, 7,  74, 89, 55,  16, 17,  91, 95, 46, 46, 8,  2,  57, 74, 22,
            74, 57, 83, 83, 11, 37, 90, 58,  39, 98, 76, 54, 32, 17,  61, 35,  37, 65, 63, 8,  2,  99, 50, 6,  75};

        std_vec::vector_ext<i32> expected_result = {
            8,  84, 28, 89, 28, 30, 13, 67,  77, 55, 34, 75, 16, 31,  14, 43,  76, 8,  99, 59, 96, 29, 49, 54, 87,
            57, 17, 23, 9,  42, 62, 83, 100, 52, 80, 15, 61, 60, 46,  67, 24,  24, 57, 68, 30, 19, 16, 35, 37, 60,
            21, 34, 1,  95, 26, 62, 96, 24,  6,  14, 21, 79, 97, 10,  66, 100, 78, 8,  18, 87, 50, 0,  29, 23, 89,
            74, 42, 60, 70, 95, 72, 38, 39,  1,  27, 87, 54, 51, 17,  76, 94,  83, 77, 89, 93, 47, 76, 2,  96, 83,
            22, 81, 57, 47, 90, 41, 65, 92,  70, 52, 31, 93, 1,  100, 60, 22,  30, 95, 19, 81, 58, 0,  60, 58, 3,
            6,  9,  99, 23, 13, 52, 62, 8,   21, 32, 93, 43, 42, 21,  53, 51,  73, 44, 21, 98, 40, 61, 93, 39, 76,
            53, 64, 39, 4,  34, 65, 10, 29,  51, 95, 77, 46, 65, 81,  8,  99,  14, 24, 4,  91, 76, 20, 10, 40, 43,
            82, 25, 64, 28, 79, 5,  18, 60,  83, 43, 46, 89, 88, 35,  78, 26,  19, 68, 12, 85, 85, 71, 78, 20, 75,
            85, 33, 44, 56, 56, 4,  92, 77,  81, 2,  92, 32, 95, 30,  96, 89,  31, 63, 52, 0,  23, 15, 96, 98, 5,
            79, 34, 92, 82, 25, 54, 60, 77,  46, 43, 79, 10, 37, 72,  40, 86,  76, 63, 41, 12, 7,  10, 56, 79, 63,
            9,  50, 88, 71, 97, 36, 92, 16,  82, 14, 92, 3,  27, 5,   82, 74,  27, 37, 76, 11, 19, 40, 10, 45, 41,
            30, 64, 93, 6,  2,  2,  6,  46,  69, 18, 81, 25, 53, 2,   22, 93,  31, 66, 91, 83, 68, 88, 46, 76, 22,
            4,  12, 47, 55, 69, 81, 21, 43,  21, 70, 32, 21, 12, 86,  20, 4,   45, 85, 15, 58, 42, 60, 44, 98, 65,
            10, 18, 42, 29, 24, 65, 59, 76,  8,  72, 78, 75, 96, 91,  58, 25,  96, 72, 81, 92, 11, 80, 18, 39, 42,
            86, 88, 64, 98, 20, 69, 56, 54,  10, 41, 7,  74, 89, 55,  16, 17,  91, 95, 46, 46, 8,  2,  57, 74, 22,
            74, 57, 83, 83, 11, 37, 90, 58,  39, 98, 76, 54, 32, 17,  61, 35,  37, 65, 63, 8,  2,  99, 50, 6,  75};

        std::sort(expected_result.begin(), expected_result.end());

        original.sort();

        if (expected_result == original)
            this->results[test_vector_ext_enum::sort_without_compare_vector_depth_limit_is_zero] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing "
               << test_vector_ext_enum::test_names
                      [test_vector_ext_enum::sort_without_compare_vector_depth_limit_is_zero]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::sort_without_compare_vector_depth_limit_is_zero] = ss.str();
        }
    }
    void test_sort_without_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero()
    {
        std_vec::vector_ext<i32> original = {
            8,  84, 28, 89, 28, 30, 13, 67,  77, 55, 34, 75, 16, 31,  14, 43,  76, 8,  99, 59, 96, 29, 49, 54, 87,
            57, 17, 23, 9,  42, 62, 83, 100, 52, 80, 15, 61, 60, 46,  67, 24,  24, 57, 68, 30, 19, 16, 35, 37, 60,
            21, 34, 1,  95, 26, 62, 96, 24,  6,  14, 21, 79, 97, 10,  66, 100, 78, 8,  18, 87, 50, 0,  29, 23, 89,
            74, 42, 60, 70, 95, 72, 38, 39,  1,  27, 87, 54, 51, 17,  76, 94,  83, 77, 89, 93, 47, 76, 2,  96, 83,
            22, 81, 57, 47, 90, 41, 65, 92,  70, 52, 31, 93, 1,  100, 60, 22,  30, 95, 19, 81, 58, 0,  60, 58, 3,
            6,  9,  99, 23, 13, 52, 62, 8,   21, 32, 93, 43, 42, 21,  53, 51,  73, 44, 21, 98, 40, 61, 93, 39, 76};

        std_vec::vector_ext<i32> expected_result = {
            8,  84, 28, 89, 28, 30, 13, 67,  77, 55, 34, 75, 16, 31,  14, 43,  76, 8,  99, 59, 96, 29, 49, 54, 87,
            57, 17, 23, 9,  42, 62, 83, 100, 52, 80, 15, 61, 60, 46,  67, 24,  24, 57, 68, 30, 19, 16, 35, 37, 60,
            21, 34, 1,  95, 26, 62, 96, 24,  6,  14, 21, 79, 97, 10,  66, 100, 78, 8,  18, 87, 50, 0,  29, 23, 89,
            74, 42, 60, 70, 95, 72, 38, 39,  1,  27, 87, 54, 51, 17,  76, 94,  83, 77, 89, 93, 47, 76, 2,  96, 83,
            22, 81, 57, 47, 90, 41, 65, 92,  70, 52, 31, 93, 1,  100, 60, 22,  30, 95, 19, 81, 58, 0,  60, 58, 3,
            6,  9,  99, 23, 13, 52, 62, 8,   21, 32, 93, 43, 42, 21,  53, 51,  73, 44, 21, 98, 40, 61, 93, 39, 76};

        std::sort(expected_result.begin(), expected_result.end());

        original.sort();

        if (expected_result == original)
            this->results[test_vector_ext_enum::
                              sort_without_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero] =
                std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing "
               << test_vector_ext_enum::test_names
                      [test_vector_ext_enum::
                           sort_without_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero]
               << " failed. Expected: " << print_1d_array(expected_result) << " Got: " << print_1d_array(original);
            this->results[test_vector_ext_enum::
                              sort_without_compare_vector_length_greater_than_zero_and_depth_limit_greater_than_zero] =
                ss.str();
        }
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
        std::stringstream ss;
        bool fail = false;
        if (result.second.has_value()) {
            fail = true;
            ss << "Test " << test_vector_ext::test_vector_ext_enum::test_names[result.first]
               << " failed: " << result.second.value() << std::endl;
        }
        else
        {
            ss << "Test " << test_vector_ext::test_vector_ext_enum::test_names[result.first] << " passed" << std::endl;
        }

        if (fail)
            std::cout << RED(ss.str());
        else
            std::cout << GREEN(ss.str());
    }
}