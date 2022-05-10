#include <chrono>
#include <iostream>
#include <locale>
#include <memory>
#include <algorithm>
#include <execution>
#include <random>
#include <iterator>
#include <vector>
#include <iomanip>
#include <complex>

#include <boost/multiprecision/cpp_int.hpp>

#include "vector_ext.hpp"

struct separate_thousands : std::numpunct<char>
{
    char_type do_thousands_sep() const override { return ','; } // separate with commas
    string_type do_grouping() const override { return "\3"; }   // groups of 3 digit
};

template <typename T>
auto print(std::vector_ext<T>& vec)
{
    std::cout << "{ ";
    for (auto i : vec)
        std::cout << i << " ";
    std::cout << "}\n";
}

/*
template <typename T>
auto generate_positive_random_list(std::vector<T>& vec, const float ax0 = -1.618f, const float bx0 = 1.618f) -> void
{
    std::default_random_engine gen;
    std::extreme_value_distribution<double> d( static_cast<double>(ax0), static_cast<double>(bx0) );

    #pragma omp parallel for
    for (int i = 0; i < vec.size(); ++i) {
        vec.at(i) = static_cast<T>(std::abs(d(gen) * 11));
    }
}

void run() {
    std::cout << "starting..." << std::fixed << std::setprecision(7) << std::endl;

    boost::multiprecision::cpp_int exec = 0, openmp = 0;
    constexpr int iterations = 100;

    for (auto i = 0LL; i < iterations; ++i)
    {
        std::vector<int> vec_1(1ULL << 20), vec_2(1ULL << 20), ans(1ULL << 20), test(1ULL << 20);
        generate_positive_random_list(vec_1);
        std::copy(std::execution::par, vec_1.begin(), vec_1.end(), vec_2.begin());

        auto start_exec_policy = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
        std::transform(std::execution::par, vec_1.begin(), vec_1.end(), vec_2.begin(), test.begin(), [](int &n, int &m)
                       { return m + n; });
        auto stop_exec_policy = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

        auto start_omp = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

#pragma omp parallel for schedule(guided)
        for (auto j = 0LL; j < (1ULL << 20); ++j)
            ans.at(j) = vec_1.at(j) + vec_2.at(j);

        auto stop_omp = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

        if (std::equal(std::execution::par, test.begin(), test.end(), ans.begin()))
        {
            exec += (stop_exec_policy - start_exec_policy);
            openmp += (stop_omp - start_omp);
        }

        std::cout << "\r";
        std::cout << "\r" << std::setprecision(7) << std::setw(10) << i / static_cast<double>(iterations) * 100 << std::setw(10) << "% complete" << std::flush;
    }
    std::cout << "\nExecution Policy: \t" << exec / iterations << "\n";
    std::cout << "OpenMP: \t\t" << openmp / iterations << "\n";
}

void run_2() {
        auto val = 1LL << 20;
    std::vector_ext<long long> vec_1(val);
    std::vector_ext<long long> vec_2(val);
    vec_1.generate_positive_random_list();
    vec_2.generate_positive_random_list();

    std::for_each(std::execution::par, vec_1.begin(), vec_1.end(), [](long long &n){ if (!n) n += 39; });
    std::for_each(std::execution::par, vec_2.begin(), vec_2.end(), [](long long &n){ if (!n) n += 39; });

    #ifdef _OPENMP
        std::cout << "OPENMP TESTING\n";
    #else
        std::cout << "EXECUTION POLICY TESTING\n";
    #endif

    std::cout << "ADD STARTING\n";
    const auto start_exec_policy_add = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    auto fin_add = vec_1 + vec_2;
    const auto stop_exec_policy_add = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

    std::cout << "SUB STARTING\n";
    const auto start_exec_policy_sub = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    auto fin_sub = vec_1 - vec_2;
    const auto stop_exec_policy_sub = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

    std::cout << "MUL STARTING\n";
    const auto start_exec_policy_mul = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    auto fin_mul = vec_1 * vec_2;
    const auto stop_exec_policy_mul = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

    std::cout << "DIV STARTING\n";
    const auto start_exec_policy_div = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    auto fin_dev = vec_1 / vec_2;
    const auto stop_exec_policy_div = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

    auto thou = std::make_unique<separate_thousands>();
    std::cout.imbue(std::locale(std::cout.getloc(), thou.release()));

    std::cout << "ADD: " << stop_exec_policy_add - start_exec_policy_add << " ns\n";
    std::cout << "SUB: " << stop_exec_policy_sub - start_exec_policy_sub << " ns\n";
    std::cout << "MUL: " << stop_exec_policy_mul - start_exec_policy_mul << " ns\n";
    std::cout << "DIV: " << stop_exec_policy_div - start_exec_policy_div << " ns\n";
}

void run_3() {
        std::cout << "starting..." << std::fixed << std::setprecision(7) << std::endl;

    boost::multiprecision::cpp_int exec = 0, openmp = 0;
    constexpr int iterations = 100;

    for (auto i = 0LL; i < iterations; ++i)
    {
        std::vector_ext<int> vec_1(1ULL << 20), vec_2(1ULL << 20);

        const auto start_exec_policy = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
        vec_1.generate_random_list_resize(1ULL << 22, -1.618f, 1.618f);
        const auto stop_exec_policy = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

        const auto start_omp = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
        vec_2.generate_random_list_resize(1ULL << 22, -1.618f, 1.618f);
        const auto stop_omp = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

        exec += (stop_exec_policy - start_exec_policy);
        openmp += (stop_omp - start_omp);

        std::cout << "\r";
        std::cout << "\r" << std::setprecision(7) << std::setw(10) << i / static_cast<double>(iterations) * 100 << std::setw(10) << "% complete" << std::flush;
    }
    std::cout << "\nExecution Policy: \t" << exec / iterations << "\n";
    std::cout << "OpenMP: \t\t" << openmp / iterations << "\n";
}
*/

int main()
{
    std::cout << "\n\nTesting std::complex with std::vector_ext\n";

    constexpr auto val = 1LL << 20;
    std::random_device gen;
    std::uniform_int_distribution<int> dist(-300, 300);

    std::vector_ext<std::complex<double>> complex_vec(val);
    std::for_each(std::execution::par, complex_vec.begin(), complex_vec.end(), [&](std::complex<double> &n)
                { n = std::complex<double>(dist(gen), dist(gen)); });

    std::vector_ext<std::complex<double>> complex_vec_t(val);
    complex_vec_t.generate_random_list_lam([&gen, &dist](std::complex<double> &n)
                { n = std::complex<double>(dist(gen), dist(gen)); });

    std::cout << "ADD STARTING\n";
    const auto start_exec_policy_add = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    auto fin_1 = complex_vec + complex_vec_t;
    const auto stop_exec_policy_add = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

    std::cout << "SUB STARTING\n";
    const auto start_exec_policy_sub = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    auto fin_2 = complex_vec - complex_vec_t;
    const auto stop_exec_policy_sub = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

    std::cout << "MUL STARTING\n";
    const auto start_exec_policy_mul = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    auto fin_3 = complex_vec * complex_vec_t;
    const auto stop_exec_policy_mul = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

    std::cout << "DIV STARTING\n";
    const auto start_exec_policy_div = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    auto fin_4 = complex_vec / complex_vec_t;
    const auto stop_exec_policy_div = std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

    auto thou = std::make_unique<separate_thousands>();
    std::cout.imbue(std::locale(std::cout.getloc(), thou.release()));

    std::cout << "ADD: " << stop_exec_policy_add - start_exec_policy_add << " ns\n";
    std::cout << "SUB: " << stop_exec_policy_sub - start_exec_policy_sub << " ns\n";
    std::cout << "MUL: " << stop_exec_policy_mul - start_exec_policy_mul << " ns\n";
    std::cout << "DIV: " << stop_exec_policy_div - start_exec_policy_div << " ns\n";

    return 0;
}
