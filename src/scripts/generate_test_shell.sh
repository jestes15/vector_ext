#!/bin/bash

disable_main=false

for i in "$@"
do 
    if [ $i == "--disable-main" ]
    then
        disable_main=true
    fi
done

for i in "$@"
do
if [ $i != "--disable-main" ]
then
echo "
#include <iostream>
#include <map>
#include <string>
#include <optional>
" > $i.cpp
if [ $disable_main == true ]
then
echo "#define MAIN_DISBALED" >> $i.cpp
fi

echo "
namespace $i {
    namespace ${i}_enum {
        enum tests {
            example_test,
        };

        std::map<tests, std::string> test_names = {
            {example_test, \"example_test\"},
        };
    }

    class ${i}_class {
        public:
            ${i}_class() = default;
            ~${i}_class() = default;

            std::map<${i}_enum::tests, std::optional<std::string>> run() {
                example_test();

                return results;
            }

        private:
            std::map<${i}_enum::tests, std::optional<std::string>> results;

            void example_test() {
                results[${i}_enum::example_test] = std::nullopt;
            }
    };
}
" >> $i.cpp
if [ $disable_main == true ]
then
echo "#ifndef MAIN_DISBALED" >> $i.cpp
fi
echo "int main()
{
    auto test = $i::${i}_class();
    std::map<$i::${i}_enum::tests, std::optional<std::string>> results = test.run();

    for (auto const &result : results)
    {
        if (result.second.has_value())
            std::cout << \"Test \" << $i::${i}_enum::test_names[result.first]
                      << \" failed: \" << result.second.value() << std::endl;
        else
        {
            std::cout << \"Test \" << $i::${i}_enum::test_names[result.first] << \" passed\"
                      << std::endl;
        }
    }
}" >> $i.cpp
if [ $disable_main == true ]
then
echo "#endif MAIN_DISBALED" >> $i.cpp
fi
fi
done

echo "Generated $# test shell(s)"