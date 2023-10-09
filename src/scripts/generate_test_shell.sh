#!/bin/bash

REQUIRED_PKG="clang-format"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi

disable_main=false
files=0

for i in "$@"
do 
    if [ $i == "--disable-main" ]
    then
        disable_main=true
    fi
done

for i in "$@"
do

if [ "$i" != "--disable-main" ]
then

files=$((files + 1))

IFS=':' array=($i)
IFS=',' options=(${array[1]})

class_name=${array[0]}

echo "
#include <iostream>
#include <map>
#include <string>
#include <optional>
" > $class_name.cpp
if [ $disable_main == true ]
then
echo "#define MAIN_DISBALED" >> $class_name.cpp
fi

echo "
namespace $class_name {
    namespace ${class_name}_enum {
        enum tests {" >> $class_name.cpp

        if [ ${#array[@]} == 1 ]; then
            echo "example_test," >> $class_name.cpp
        else

        for element in "${options[@]}"; do
            echo "$element," >> $class_name.cpp
        done

        fi
        echo "};

        std::map<tests, std::string> test_names = {" >> $class_name.cpp

        if [ ${#array[@]} == 1 ]; then
            echo "{example_test, \"example_test\"}" >> $class_name.cpp
        else
        for element in "${options[@]}"; do
            echo "{$element, \"$element\"}," >> $class_name.cpp
        done
        fi
        echo "};
    }

    class ${class_name}_class {
        public:
            ${class_name}_class() = default;
            ~${class_name}_class() = default;

            std::map<${class_name}_enum::tests, std::optional<std::string>> run() {
                " >> $class_name.cpp

        if [ ${#array[@]} == 1 ]; then
            echo "example_test();" >> $class_name.cpp
        else
        for element in "${options[@]}"; do
            echo "${element}_test();" >> $class_name.cpp
        done
        fi

                echo "return results;
            }

        private:
            std::map<${class_name}_enum::tests, std::optional<std::string>> results;

            " >> $class_name.cpp

            if [ ${#array[@]} == 1 ]; then
            echo "void example_test() {
                results[${class_name}_enum::example_test] = std::nullopt;
            }" >> $class_name.cpp

            else
            for element in "${options[@]}"; do
            echo "void ${element}_test() {
                results[${class_name}_enum::$element] = std::nullopt;
            }" >> $class_name.cpp
            done
            fi
            
            echo "
    };
}
" >> $class_name.cpp

if [ $disable_main == true ]
then
echo "#ifndef MAIN_DISBALED" >> $class_name.cpp
fi

echo "int main()
{
    auto test = $class_name::${class_name}_class();
    std::map<$class_name::${class_name}_enum::tests, std::optional<std::string>> results = test.run();

    for (auto const &result : results)
    {
        if (result.second.has_value())
            std::cout << \"Test \" << $class_name::${class_name}_enum::test_names[result.first]
                      << \" failed: \" << result.second.value() << std::endl;
        else
        {
            std::cout << \"Test \" << $class_name::${class_name}_enum::test_names[result.first] << \" passed\"
                      << std::endl;
        }
    }
}" >> $class_name.cpp
if [ $disable_main == true ]
then
echo "#endif MAIN_DISBALED" >> $class_name.cpp
fi

clang-format -i -style=Microsoft $class_name.cpp

fi
done

echo "Generated $files test shell(s)"