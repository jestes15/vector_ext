#include "quaternion.cuh"
#include "types.cuh"

#include <iostream>
#include <map>
#include <optional>
#include <sstream>

namespace test_quaternion
{
namespace test_quaternion_enum
{
enum tests
{
    default_constructor,
    four_parameter_constructor,
    three_parameter_constructor,
    two_parameter_constructor,
    one_parameter_constructor,
    unit_vector_constructor,
    unit_vector_constructor_no_q0,
    classic_array_constructor,
    classic_array_constructor_no_q0,
    standard_array_constructor,
    standard_array_constructor_no_q0,
    standard_array_constructor_four,
    addition,
    subtraction,
    multiplication,
    scalar_multiplication,
    conjugate,
    norm,
    inverse,
    rotation,
    interpolate
};

std::map<tests, std::string> test_names = {{default_constructor, "default_constructor"},
                                           {four_parameter_constructor, "four_parameter_constructor"},
                                           {three_parameter_constructor, "three_parameter_constructor"},
                                           {two_parameter_constructor, "two_parameter_constructor"},
                                           {one_parameter_constructor, "one_parameter_constructor"},
                                           {unit_vector_constructor, "unit_vector_constructor"},
                                           {unit_vector_constructor_no_q0, "unit_vector_constructor_no_q0"},
                                           {classic_array_constructor, "classic_array_constructor"},
                                           {classic_array_constructor_no_q0, "classic_array_constructor_no_q0"},
                                           {standard_array_constructor, "standard_array_constructor"},
                                           {standard_array_constructor_no_q0, "standard_array_constructor_no_q0"},
                                           {standard_array_constructor_four, "standard_array_constructor_four"},
                                           {addition, "addition"},
                                           {subtraction, "subtraction"},
                                           {multiplication, "multiplication"},
                                           {scalar_multiplication, "scalar_multiplication"},
                                           {conjugate, "conjugate"},
                                           {norm, "norm"},
                                           {inverse, "inverse"},
                                           {rotation, "rotation"},
                                           {interpolate, "interpolate"}};

} // namespace test_quaternion_enum

class test_quaternion_class
{
  public:
    test_quaternion_class() = default;
    ~test_quaternion_class() = default;

    std::map<test_quaternion_enum::tests, std::optional<std::string>> run()
    {
        test_default_constructor();

        test_four_parameter_constructor();
        test_three_parameter_constructor();
        test_two_parameter_constructor();
        test_one_parameter_constructor();

        test_unit_vector_constructor();
        test_unit_vector_constructor_no_q0();

        test_classic_array_constructor();
        test_classic_array_constructor_no_q0();

        test_standard_array_constructor();
        test_standard_array_constructor_no_q0();
        test_standard_array_constructor_four();

        test_addition();
        test_subtraction();
        test_multiplication();

        test_interpolation();
        return results;
    }

  private:
    std::map<test_quaternion_enum::tests, std::optional<std::string>> results;

    void test_default_constructor()
    {
        quaternion q = quaternion();
        quaternion expected_result = quaternion(0, 0, 0, 0);

        if (q == expected_result)
            this->results[test_quaternion_enum::default_constructor] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::default_constructor]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::default_constructor] = ss.str();
        }
    }

    void test_four_parameter_constructor()
    {
        quaternion q = quaternion(1, 2, 3, 4);
        quaternion expected_result = quaternion(1, 2, 3, 4);

        if (q == expected_result)
            this->results[test_quaternion_enum::four_parameter_constructor] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::four_parameter_constructor]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::four_parameter_constructor] = ss.str();
        }
    }

    void test_three_parameter_constructor()
    {
        quaternion q = quaternion(1, 2, 3);
        quaternion expected_result = quaternion(1, 2, 3, 0);

        if (q == expected_result)
            this->results[test_quaternion_enum::three_parameter_constructor] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::three_parameter_constructor]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::three_parameter_constructor] = ss.str();
        }
    }

    void test_two_parameter_constructor()
    {
        quaternion q = quaternion(1, 2);
        quaternion expected_result = quaternion(1, 2, 0, 0);

        if (q == expected_result)
            this->results[test_quaternion_enum::two_parameter_constructor] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::two_parameter_constructor]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::two_parameter_constructor] = ss.str();
        }
    }

    void test_one_parameter_constructor()
    {
        quaternion q = quaternion(1);
        quaternion expected_result = quaternion(1, 0, 0, 0);

        if (q == expected_result)
            this->results[test_quaternion_enum::one_parameter_constructor] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::one_parameter_constructor]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::one_parameter_constructor] = ss.str();
        }
    }

    void test_unit_vector_constructor()
    {
        unit_vector<int> uv = {1, 2, 3};
        quaternion q = quaternion(25, uv);
        quaternion expected_result = quaternion(25, 1, 2, 3);

        if (q == expected_result)
            this->results[test_quaternion_enum::unit_vector_constructor] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::unit_vector_constructor]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::unit_vector_constructor] = ss.str();
        }
    }

    void test_unit_vector_constructor_no_q0()
    {
        struct unit_vector<int> uv =
        {
            1, 2, 3
        };
        quaternion q = quaternion(uv);
        quaternion expected_result = quaternion(0, 1, 2, 3);

        if (q == expected_result)
            this->results[test_quaternion_enum::unit_vector_constructor_no_q0] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::unit_vector_constructor_no_q0]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::unit_vector_constructor_no_q0] = ss.str();
        }
    }

    void test_classic_array_constructor()
    {
        int arr[3] = {3, 4, 5};
        quaternion q = quaternion(91, arr);
        quaternion expected_result = quaternion(91, 3, 4, 5);

        if (q == expected_result)
            this->results[test_quaternion_enum::classic_array_constructor_no_q0] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::classic_array_constructor_no_q0]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::classic_array_constructor_no_q0] = ss.str();
        }
    }

    void test_classic_array_constructor_no_q0()
    {
        int arr[3] = {3, 4, 5};
        quaternion q = quaternion(arr);
        quaternion expected_result = quaternion(0, 3, 4, 5);

        if (q == expected_result)
            this->results[test_quaternion_enum::classic_array_constructor] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::classic_array_constructor]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::classic_array_constructor] = ss.str();
        }
    }

    void test_standard_array_constructor()
    {
        std::array<int, 3> arr = {3, 4, 5};
        quaternion q = quaternion(91, arr);
        quaternion expected_result = quaternion(91, 3, 4, 5);

        if (q == expected_result)
            this->results[test_quaternion_enum::standard_array_constructor] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::standard_array_constructor]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::standard_array_constructor] = ss.str();
        }
    }

    void test_standard_array_constructor_no_q0()
    {
        std::array<int, 3> arr = {3, 4, 5};
        quaternion q = quaternion(arr);
        quaternion expected_result = quaternion(0, 3, 4, 5);

        if (q == expected_result)
            this->results[test_quaternion_enum::standard_array_constructor_no_q0] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::standard_array_constructor_no_q0]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::standard_array_constructor_no_q0] = ss.str();
        }
    }

    void test_standard_array_constructor_four()
    {
        std::array<int, 4> arr = {2, 3, 4, 5};
        quaternion q = quaternion(arr);
        quaternion expected_result = quaternion(2, 3, 4, 5);

        if (q == expected_result)
            this->results[test_quaternion_enum::standard_array_constructor_four] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::standard_array_constructor_four]
               << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::standard_array_constructor_four] = ss.str();
        }
    }

    void test_addition()
    {
        quaternion q1(1, 2, 3, 4);
        quaternion q2(5, 6, 7, 8);

        quaternion expected_result = quaternion(6, 8, 10, 12);
        quaternion result = q1 + q2;

        if (result == expected_result)
            this->results[test_quaternion_enum::addition] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::addition]
               << " failed. Expected: " << expected_result << " Got: " << result;
            this->results[test_quaternion_enum::addition] = ss.str();
        }
    }

    void test_subtraction()
    {
        quaternion q1(1, 2, 3, 4);
        quaternion q2(5, 6, 7, 8);

        quaternion expected_result = quaternion(-4, -4, -4, -4);
        quaternion result = q1 - q2;

        if (result == expected_result)
            this->results[test_quaternion_enum::subtraction] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::subtraction]
               << " failed. Expected: " << expected_result << " Got: " << result;
            this->results[test_quaternion_enum::subtraction] = ss.str();
        }
    }

    void test_multiplication()
    {
        quaternion q1(1, 2, 3, 4);
        quaternion q2(5, 6, 7, 8);

        quaternion expected_result = quaternion(-60, 12, 30, 24);
        quaternion result = q1 * q2;

        if (result == expected_result)
            this->results[test_quaternion_enum::multiplication] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::multiplication]
               << " failed. Expected: " << expected_result << " Got: " << result;
            this->results[test_quaternion_enum::multiplication] = ss.str();
        }
    }

    void test_interpolation()
    {
        quaternion q1(1, 2, 3, 4);
        quaternion q2(5, 6, 7, 8);

        quaternion q1_normalized = q1.normalize();
        quaternion q2_normalized = q2.normalize();

        std::optional<quaternion> result =
            q1_normalized.interpolate(q2_normalized, quaternion_interpolation_method::slerp, 0.5);

        quaternion expected_result = quaternion(0.283023303767278, 0.413232827790139, 0.543442351813000, 0.673651875835861);

        if (!result.has_value())
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::interpolate]
               << " failed. Expected: " << expected_result << " Got: None";
            this->results[test_quaternion_enum::interpolate] = ss.str();
            return;
        }
        else if (result.value() == expected_result)
            this->results[test_quaternion_enum::interpolate] = std::nullopt;
        else
        {
            std::stringstream ss;
            ss << "Testing " << test_quaternion_enum::test_names[test_quaternion_enum::interpolate]
               << " failed. Expected: " << expected_result << " Got: " << result.value();
            this->results[test_quaternion_enum::interpolate] = ss.str();
        }
    }
};
} // namespace test_quaternion

i32 main()
{
    test_quaternion::test_quaternion_class test = test_quaternion::test_quaternion_class();

    std::map<test_quaternion::test_quaternion_enum::tests, std::optional<std::string>> results = test.run();

    for (auto const &result : results)
    {
        if (result.second.has_value())
            std::cout << "Test " << test_quaternion::test_quaternion_enum::test_names[result.first]
                      << " failed: " << result.second.value() << std::endl;
        else
        {
            std::cout << "Test " << test_quaternion::test_quaternion_enum::test_names[result.first] << " passed"
                      << std::endl;
        }
    }
    return 0;
}