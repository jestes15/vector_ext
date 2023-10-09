
#include <iostream>
#include <map>
#include <string>
#include <optional>


namespace simd_vector_operations_x86 {
    namespace simd_vector_operations_x86_enum {
        enum tests {
            example_test,
        };

        std::map<tests, std::string> test_names = {
            {example_test, "example_test"},
        };
    }

    class simd_vector_operations_x86_class {
        public:
            simd_vector_operations_x86_class() = default;
            ~simd_vector_operations_x86_class() = default;

            std::map<simd_vector_operations_x86_enum::tests, std::optional<std::string>> run() {
                example_test();

                return results;
            }

        private:
            std::map<simd_vector_operations_x86_enum::tests, std::optional<std::string>> results;

            void example_test() {
                results[simd_vector_operations_x86_enum::example_test] = std::nullopt;
            }
    };
}

int main()
{
    auto test = simd_vector_operations_x86::simd_vector_operations_x86_class();
    std::map<simd_vector_operations_x86::simd_vector_operations_x86_enum::tests, std::optional<std::string>> results = test.run();

    for (auto const &result : results)
    {
        if (result.second.has_value())
            std::cout << "Test " << simd_vector_operations_x86::simd_vector_operations_x86_enum::test_names[result.first]
                      << " failed: " << result.second.value() << std::endl;
        else
        {
            std::cout << "Test " << simd_vector_operations_x86::simd_vector_operations_x86_enum::test_names[result.first] << " passed"
                      << std::endl;
        }
    }
}
