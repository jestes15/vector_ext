#include "quaternion.cuh"
#include "types.cuh"

#include <iostream>
#include <sstream>
#include <optional>
#include <unordered_map>

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
    array_constructor,
    addition,
    subtraction,
    multiplication,
    scalar_multiplication,
    conjugate,
    norm,
    inverse,
    rotation
};

std::unordered_map<tests, std::string> test_names = {
    {default_constructor, "default_constructor"},
    {four_parameter_constructor, "four_parameter_constructor"},
    {three_parameter_constructor, "three_parameter_constructor"},
    {two_parameter_constructor, "two_parameter_constructor"},
    {one_parameter_constructor, "one_parameter_constructor"},
    {unit_vector_constructor, "unit_vector_constructor"},
    {array_constructor, "array_constructor"},
    {addition, "addition"},
    {subtraction, "subtraction"},
    {multiplication, "multiplication"},
    {scalar_multiplication, "scalar_multiplication"},
    {conjugate, "conjugate"},
    {norm, "norm"},
    {inverse, "inverse"},
    {rotation, "rotation"}
};

} // namespace test_quaternion_enum
class test_quaternion_class
{
  public:
    test_quaternion_class() = default;
    ~test_quaternion_class() = default;

    std::unordered_map<test_quaternion_enum::tests, std::optional<std::string>> run()
    {
        test_addition();
        test_subtraction();
        return results;
    }

  private:
    std::unordered_map<test_quaternion_enum::tests, std::optional<std::string>> results;

    void test_constructor_default() {
        quaternion q = quaternion<int>();
        quaternion expected_result = quaternion(0, 0, 0, 0);

        if (q == expected_result)
            this->results[test_quaternion_enum::default_constructor] = std::nullopt;
        else {
            std::stringstream ss;
            ss << "Testing" << test_quaternion_enum::test_names[test_quaternion_enum::default_constructor] << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::default_constructor] = ss.str();
        }
    }

    void test_constructor_four_parameter() {
        quaternion q = quaternion<int>(1, 2, 3, 4);
        quaternion expected_result = quaternion(1, 2, 3, 4);

        if (q == expected_result)
            this->results[test_quaternion_enum::four_parameter_constructor] = std::nullopt;
        else {
            std::stringstream ss;
            ss << "Testing" << test_quaternion_enum::test_names[test_quaternion_enum::four_parameter_constructor] << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::four_parameter_constructor] = ss.str();
        }
    }

    void test_constructor_three_parameter() {
        quaternion q = quaternion<int>(1, 2, 3);
        quaternion expected_result = quaternion(1, 2, 3, 0);

        if (q == expected_result)
            this->results[test_quaternion_enum::three_parameter_constructor] = std::nullopt;
        else {
            std::stringstream ss;
            ss << "Testing" << test_quaternion_enum::test_names[test_quaternion_enum::three_parameter_constructor] << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::three_parameter_constructor] = ss.str();
        }
    }

    void test_constructor_two_parameter() {
        quaternion q = quaternion<int>(1, 2);
        quaternion expected_result = quaternion(1, 2, 0, 0);

        if (q == expected_result)
            this->results[test_quaternion_enum::two_parameter_constructor] = std::nullopt;
        else {
            std::stringstream ss;
            ss << "Testing" << test_quaternion_enum::test_names[test_quaternion_enum::two_parameter_constructor] << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::two_parameter_constructor] = ss.str();
        }
    }

    void test_constructor_one_parameter() {
        quaternion q = quaternion<int>(1);
        quaternion expected_result = quaternion(1, 0, 0, 0);

        if (q == expected_result)
            this->results[test_quaternion_enum::one_parameter_constructor] = std::nullopt;
        else {
            std::stringstream ss;
            ss << "Testing" << test_quaternion_enum::test_names[test_quaternion_enum::one_parameter_constructor] << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::one_parameter_constructor] = ss.str();
        }
    }

    void test_constructor_unit_vector_no_q0() {
        unit_vector<int> uv = unit_vector<int>(1, 2, 3);
        quaternion q = quaternion<int>(uv);
        quaternion expected_result = quaternion(0, 1, 2, 3);

        if (q == expected_result)
            this->results[test_quaternion_enum::unit_vector_constructor] = std::nullopt;
        else {
            std::stringstream ss;
            ss << "Testing" << test_quaternion_enum::test_names[test_quaternion_enum::unit_vector_constructor] << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::unit_vector_constructor] = ss.str();
        }
    }

    void test_constructor_array() {
        quaternion q = quaternion<int>(std::array<int, 4>{1, 2, 3, 4});
        quaternion expected_result = quaternion(1, 2, 3, 4);

        if (q == expected_result)
            this->results[test_quaternion_enum::array_constructor] = std::nullopt;
        else {
            std::stringstream ss;
            ss << "Testing" << test_quaternion_enum::test_names[test_quaternion_enum::array_constructor] << " failed. Expected: " << expected_result << " Got: " << q;
            this->results[test_quaternion_enum::array_constructor] = ss.str();
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
        else {
            std::stringstream ss;
            ss << "Testing" << test_quaternion_enum::test_names[test_quaternion_enum::addition] << " failed. Expected: " << expected_result << " Got: " << result;
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
        else {
            std::stringstream ss;
            ss << "Testing" << test_quaternion_enum::test_names[test_quaternion_enum::subtraction] << " failed. Expected: " << expected_result << " Got: " << result;
            this->results[test_quaternion_enum::subtraction] = ss.str();
        }
    }
};
} // namespace test_quaternion

i32 main()
{
    test_quaternion::test_quaternion_class test = test_quaternion::test_quaternion_class();

    std::unordered_map<test_quaternion::test_quaternion_enum::tests, std::optional<std::string>> results = test.run();

    for (auto const &result : results)
    {
        if (result.second.has_value())
            std::cout << "Test " << test_quaternion::test_quaternion_enum::test_names[result.first] << " failed: " << result.second.value() << std::endl;
        else {
            std::cout << "Test " << test_quaternion::test_quaternion_enum::test_names[result.first] << " passed" << std::endl;
        }
    }
    return 0;
}