#include "quaternion.cuh"
#include "types.cuh"

#include <iostream>
#include <unordered_map>

namespace test_quaternion
{
namespace test_quaternion_enum
{
enum tests
{
    addition,
    multiplication,
    scalar_multiplication,
    conjugate,
    norm,
    inverse,
    rotation
};
} // namespace test_quaternion_enum
class test_quaternion_class
{
  public:
    test_quaternion_class() = default;
    ~test_quaternion_class() = default;

    std::unordered_map<test_quaternion_enum::tests, std::pair<i64, std::string>> run()
    {
        test_addition();
        return results;
    }

  private:
    std::unordered_map<test_quaternion_enum::tests, std::pair<i64, std::string>> results;

    void test_addition()
    {
        quaternion q1(1, 2, 3, 4);
        quaternion q2(5, 6, 7, 8);

        quaternion expected_result = quaternion(6, 8, 10, 12);
		quaternion result = q1 + q2;

		if (result == expected_result)
			this->results[test_quaternion_enum::addition] = std::make_pair(0, "Test Passed");
		else
            this->results[test_quaternion_enum::addition] = std::make_pair(1, "Test Failed");
    }
};
} // namespace test_quaternion

i32 main()
{
    test_quaternion::test_quaternion_class test = test_quaternion::test_quaternion_class();

    std::unordered_map<test_quaternion::test_quaternion_enum::tests, std::pair<i64, std::string>> results = test.run();
    return 0;
}