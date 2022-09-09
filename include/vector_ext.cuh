#pragma once

#include <cmath>
#include <functional>
#include <iterator>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>
#include <limits>

// TODO : Finish comments for all functions

#if __cplusplus > 201703L
#include <exception>
#elif defined(USE_CUDA)
#include "kernel_impl.cuh"
#define NO_EXEC
#endif

using cll = const long long;
using ll = long long;

constexpr int MAX_INT = std::numeric_limits<int>::max();

namespace std_vec
{
    template <typename T>
    class vector_ext : public std::vector<T>
    {
    private:
        /* Calculates the depth limit given the size of a vector
         * Usage: depth_limit(n) where n is the size of the vector
         */
        auto depth_limit(const long long size)
        {
            return static_cast<long long>(2 * floor(log(size)));
        }

        /* Swaps e and b
         * Usage: swap(*i, *j) where i and j are two variables
         */
        auto swap(T& a, T& b)
        {
            auto temp = std::move(a);
            a = std::move(b);
            b = std::move(temp);
        }

        /* Finds the partition index for quick sort
         * Usage: partition_iterator(std::begin(vector), std::end(vector), std::less<>())
         */
        template <typename _Iter, typename Compare>
        auto partition_iterator(_Iter first, _Iter last, Compare comp)
        {
            auto pivot = std::prev(last, 1);
            auto i = first;
            for (auto j = first; j != pivot; ++j)
            {
                if (comp(*j, *pivot))
                {
                    this->swap(*i++, *j);
                }
            }
            this->swap(*i, *pivot);
            return i;
        }

        /* Sorts vector using quicksort
         * Usage: _quick_sort(std::begin(vector), std::end(vector), std::less<>())
         */
        template <typename _Iter, typename Compare>
        auto _quick_sort(_Iter first, _Iter last, Compare comp) -> void
        {
            if (std::distance(first, last) > 1)
            {
                auto bound = partition_iterator(first, last, comp);
                _quick_sort(first, bound, comp);
                _quick_sort(bound + 1, last, comp);
            }
        }

        /* Driver for merge sort
         * Usage: mergesortInternal(std::begin(vector), std::end(vector), std::less<>(), std::begin(buffer))
         */
        template <typename _Iter, typename Compare, typename buff>
        void mergesortInternal(const _Iter first, const _Iter last, const Compare comp, const buff firstMerge)
        {
            const std::size_t n = last - first;

            if (n <= 1)
                return;

            const std::size_t m = n / 2;

            mergesortInternal(first, first + m, comp, firstMerge);
            mergesortInternal(first + m, last, comp, firstMerge);

            auto merge = firstMerge;

            auto lower = first;
            auto upper = first + m;

            while (lower != first + m && upper != last)
                *(merge++) = comp(*lower, *upper) ? *(lower++) : *(upper++);

            std::move(lower, first + m, merge);
            std::move(upper, last, merge);

            std::move(firstMerge, firstMerge + n, first);
        }

        /* Driver for heap sort, std::make_heap is not required before use
         * Usage: _heap_sort(std::begin(vector), std::end(vector), std::less<>())
         */
        template <typename _Iter, class Compare>
        inline auto _heap_sort(_Iter first, _Iter last, const Compare comp)
        {
            std::make_heap(first, last, comp);
            for (; last - first >= 2; last--)
                std::pop_heap(first, last, comp);
        }

        /* Driver for insertion sort
         * Usage: _insertion_sort(std::begin(vector), std::end(vector), std::less<>())
         */
        template <typename _Iter, typename Compare>
        auto _insertion_sort(_Iter begin, _Iter end, Compare comp)
        {
            for (auto it = begin + 1; it != end; ++it)
            {
                auto key = it;

                for (auto i = it - 1; i >= begin; --i)
                {
                    if (comp(*key, *i))
                    {
                        std::swap(*i, *key);
                        key--;
                    }
                    else
                        break;
                }
            }
        }

    protected:
        static auto resize_check(cll n)
        {
            if (n < 0)
            {
                std::string err = "vector_ext::resize_check: resize request failed due to an invalid request";
                throw std::domain_error(err);
            }
        }
        auto range_check(cll n) const
        {
            if (static_cast<unsigned long long>(abs(n)) >= this->size())
            {
                const std::string err = "vector_ext::range_check: n >= this->size()";
                throw std::out_of_range(err);
            }
        }
        static auto const_range_check(cll n, cll size)
        {
            if (std::abs(n) >= size)
            {
                const std::string err = "vector_ext::range_check: n >= size";
                throw std::out_of_range(err);
            }
        }
        static auto const_pure_val_range_check(cll n, cll size)
        {
            if (n >= size)
            {
                const std::string err = "vector_ext::range_check: n >= size";
                throw std::out_of_range(err);
            }
        }
        static auto nothrow_const_range_check(cll n, cll size) noexcept
        {
            if (std::abs(n) >= size)
                return false;
            return true;
        }
        static auto nothrow_pure_val_range_check(cll n, cll size) noexcept
        {
            if (n >= size)
                return false;
            return true;
        }
        auto range_check_plus_one(cll n) const
        {
            if (static_cast<long int>(std::abs(n)) >= static_cast<long int>(this->size()) + 1)
            {
                const std::string err = "vector_ext::range_check_plus_one: n >= this->size() + 1";
                throw std::out_of_range(err);
            }
        }
        [[nodiscard]] auto get_true_place(cll n) const noexcept
        {
            if (std::abs(n) == n)
                return n;
            return static_cast<int>(this->size()) + n;
        }
        static auto size_check(vector_ext<T>& vec1, vector_ext<T>& vec2)
        {
            if (vec1.size() != vec2.size())
            {
                const std::string err = "vector_ext::size_check: vec1.size() != vec2.size()";
                throw std::range_error(err);
            }
        }

    public:
        // Specialization
        using std::vector<T>::vector;

        // Member Functions
        using std::vector<T>::operator=;
        using std::vector<T>::assign;
        using std::vector<T>::get_allocator;

        // Element Access
        using std::vector<T>::operator[];
        using std::vector<T>::front;
        using std::vector<T>::back;
        using std::vector<T>::data;

        // Iterators
        using std::vector<T>::begin;
        using std::vector<T>::cbegin;
        using std::vector<T>::end;
        using std::vector<T>::cend;
        using std::vector<T>::rbegin;
        using std::vector<T>::crbegin;
        using std::vector<T>::rend;
        using std::vector<T>::crend;

        // Capacity
        using std::vector<T>::empty;
        using std::vector<T>::size;
        using std::vector<T>::max_size;
        using std::vector<T>::reserve;
        using std::vector<T>::capacity;
        using std::vector<T>::shrink_to_fit;

        // Modifiers
        using std::vector<T>::clear;
        using std::vector<T>::insert;
        using std::vector<T>::emplace;
        using std::vector<T>::erase;
        using std::vector<T>::push_back;
        using std::vector<T>::emplace_back;
        using std::vector<T>::pop_back;
        using std::vector<T>::resize;
        using std::vector<T>::swap;

        [[nodiscard]] auto at(const long long n) -> T&
        {
            range_check(n);
            auto num = get_true_place(n);
            return (*this)[num];
        }

        auto operator+(vector_ext<T>& vector_obj) -> vector_ext<T>
        {
            size_check(*this, vector_obj);
            vector_ext<T> ret_vec(this->size());

            #if !defined(_OPENMP) && !defined(NO_EXEC)
                std::transform(std::execution::par_unseq, this->begin(), this->end(), vector_obj.begin(), ret_vec.begin(), [](T& a, T& b)
                    { return a + b; });
            #elif defined(_OPENMP)
                #pragma omp parallel for schedule(guided)
                for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
                    ret_vec.at(i) = this->at(i) + vector_obj.at(i);
            #elif defined(USE_CUDA)
                user_space::add(ret_vec.data(), this->data(), vector_obj.data(), ret_vec.size());
            #else
                for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
                    ret_vec.at(i) = this->at(i) + vector_obj.at(i);
            #endif

            return ret_vec;
        }
        auto operator-(vector_ext<T>& vector_obj) -> vector_ext<T>
        {
            size_check(*this, vector_obj);
            vector_ext<T> ret_vec(this->size());

            #if !defined(_OPENMP) && !defined(NO_EXEC)
                std::transform(std::execution::par_unseq, this->begin(), this->end(), vector_obj.begin(), ret_vec.begin(), [](T& a, T& b)
                    { return a - b; });
            #elif defined(_OPENMP)
                #pragma omp parallel for schedule(guided)
                for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
                    ret_vec.at(i) = this->at(i) - vector_obj.at(i);
            #elif defined(USE_CUDA)
                user_space::sub(ret_vec.data(), this->data(), vector_obj.data(), ret_vec.size());
            #else
                for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
                    ret_vec.at(i) = this->at(i) - vector_obj.at(i);
            #endif

            return ret_vec;
        }
        auto operator*(vector_ext<T>& vector_obj) -> vector_ext<T>
        {
            size_check(*this, vector_obj);
            vector_ext<T> ret_vec(this->size());

            #if !defined(_OPENMP) && !defined(NO_EXEC)
                std::transform(std::execution::par_unseq, this->begin(), this->end(), vector_obj.begin(), ret_vec.begin(), [](T& a, T& b)
                    { return a * b; });
            #elif defined(_OPENMP)
                #pragma omp parallel for schedule(guided)
                for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
                    ret_vec.at(i) = this->at(i) * vector_obj.at(i);
            #elif defined(USE_CUDA)
                user_space::mul(ret_vec.data(), this->data(), vector_obj.data(), ret_vec.size());
            #else
                for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
                    ret_vec.at(i) = this->at(i) * vector_obj.at(i);
            #endif

            return ret_vec;
        }
        auto operator/(vector_ext<T>& vector_obj) -> vector_ext<T>
        {
            for (auto& i : vector_obj)
                if (i == 0)
                    throw std::range_error("vector_ext::operator/: vector_obj has 0");
            
            size_check(*this, vector_obj);
            vector_ext<T> ret_vec(this->size());
            #if !defined(_OPENMP) && !defined(NO_EXEC)
                std::transform(std::execution::par_unseq, this->begin(), this->end(), vector_obj.begin(), ret_vec.begin(), [](T& a, T& b)
                    { return a / b; });
            #elif defined(_OPENMP)
                #pragma omp parallel for schedule(guided)
                for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
                    ret_vec.at(i) = this->at(i) / vector_obj.at(i);
            #elif defined(USE_CUDA)
                user_space::div(ret_vec.data(), this->data(), vector_obj.data(), ret_vec.size());
            #else
                for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
                    ret_vec.at(i) = this->at(i) / vector_obj.at(i);
            #endif

            return ret_vec;
        }

        auto operator++() -> vector_ext<T>
        {
            auto copy = *this;
            vector_ext<T> new_array(this->size() + 1);
            new_array.at(0) = 0;

            #pragma omp parallel for schedule(guided)
            for (long long i = 1; (i - 1) < this->size(); ++i)
                new_array.at(i) = this->at(i - 1);
            *this = new_array;
            return copy;
        }
        auto operator++(int) -> vector_ext<T>&
        {
            this->resize(this->size() + 1);
            return *this;
        }
        auto operator--() -> T
        {
            auto val = this->at(0);
            vector_ext<T> new_array(this->size() - 1);

            #pragma omp parallel for schedule(guided)
            for (long long i = 1; i < this->size(); ++i)
                new_array.at(i - 1) = this->at(i);
            *this = std::move(new_array);
            return val;
        }
        auto operator--(int) -> T
        {
            T val = this->at(-1);
            this->resize(this->size() - 1);
            return val;
        }

        template <typename Compare>
        auto quick_sort(Compare comp) -> void
        {
            _quick_sort(this->begin(), this->end(), comp);
        }
        auto quick_sort() -> void
        {
            _quick_sort(this->begin(), this->end(), std::less<>{});
        }

        template <typename Compare>
        auto merge_sort(const Compare comp)
        {
            vector_ext<T> mergeSpace(this->end() - this->begin());
            mergesortInternal(this->begin(), this->end(), comp, mergeSpace.begin());
        }
        auto merge_sort()
        {
            vector_ext<T> mergeSpace(this->end() - this->begin());
            mergesortInternal(this->begin(), this->end(), std::less<>{}, mergeSpace.begin());
        }

        template <typename Compare>
        auto heap_sort(const Compare comp)
        {
            _heap_sort(this->begin(), this->end(), comp);
        }
        auto heap_sort()
        {
            _heap_sort(this->begin(), this->end(), std::less<>{});
        }

        template <typename Compare>
        auto insertion_sort(const Compare comp)
        {
            _insertion_sort(this->begin(), this->end(), comp);
        }
        auto insertion_sort()
        {
            _insertion_sort(this->begin(), this->end(), std::less<>{});
        }

        template <typename Compare>
        auto sort(Compare comp)
        {
            auto size = std::distance(this->begin(), this->end());
            constexpr auto insertion_sort_max_val = 16;

            if (size < insertion_sort_max_val)
                _insertion_sort(this->begin(), this->end(), comp);

            else if (depth_limit(size) == 0)
                _heap_sort(this->begin(), this->end(), comp);

            else
                _quick_sort(this->begin(), this->end(), comp);
        }
        auto sort()
        {
            auto size = std::distance(this->begin(), this->end());
            constexpr auto insertion_sort_max_val = 16;

            if (size < insertion_sort_max_val)
                _insertion_sort(this->begin(), this->end(), std::less<>{});

            else if (depth_limit(size) == 0)
                _heap_sort(this->begin(), this->end(), std::less<>{});

            else
                _quick_sort(this->begin(), this->end(), std::less<>{});
        }

        template <typename _Function>
        auto generate_random_list_lam(const _Function& function)
        {
            #if !defined(NO_EXEC) && !defined(_OPENMP)
                std::for_each(std::execution::par, this->begin(), this->end(), function);
            #elif defined(_OPENMP)
                #pragma omp parallel for schedule(guided)
                for (int i = 0; i < this->size(); ++i)
                {
                    function(this->at(i));
                }
            #else
                for (auto& i : *this)
                    function(i);
            #endif
        }
        auto generate_random_list_resize(cll length, cll ax0 = -300, cll bx0 = 300)
        {
            resize_check(length);
            this->resize(length);

            std::random_device gen;
            std::uniform_int_distribution<int> dist(ax0, bx0);

            #if !defined(NO_EXEC) && !defined(_OPENMP)
                std::for_each(std::execution::par, this->begin(), this->end(), [&](T& n) {
                    auto val = static_cast<T>(dist(gen) * dist(gen));
                    n = val ? val : 1;
                    });
            #elif defined(_OPENMP)
                #pragma omp parallel for schedule(guided)
                for (int i = 0; i < this->size(); ++i) {
                    auto temp = static_cast<T>(dist(gen) * dist(gen));
                    this->at(i) = (temp) ? temp : 1;
                }
            #else
                std::for_each(this->begin(), this->end(), [&](T& n) {
                    auto val = static_cast<T>(dist(gen) * dist(gen));
                    n = val ? val : 1;
                    });
            #endif
        }
        auto generate_random_list(cll ax0 = -300, cll bx0 = 300)
        {
            std::random_device gen;
            std::uniform_int_distribution<int> dist(ax0, bx0);

        #if !defined(NO_EXEC) && !defined(_OPENMP)
            std::for_each(std::execution::par, this->begin(), this->end(), [&](T& n) {
                auto val = static_cast<T>(dist(gen) * dist(gen));
                n = val ? val : 1;
                });
        #elif defined(_OPENMP)
            #pragma omp parallel for schedule(guided)
                for (int i = 0; i < this->size(); ++i) {
                    auto val = static_cast<T>(dist(gen) * dist(gen));
                    this->at(i) = val ? val : 1;
                }
        #else
            std::for_each(this->begin(), this->end(), [&](T& n) {
                auto val = static_cast<T>(dist(gen) * dist(gen));
                n = val ? val : 1;
                });
        #endif
        }
        auto generate_positive_random_list(cll ax0 = -300, cll bx0 = 300)
        {
            std::random_device gen;
            std::uniform_int_distribution<int> dist(ax0, bx0);

            #if !defined(NO_EXEC) && !defined(_OPENMP)
                std::for_each(std::execution::par, this->begin(), this->end(), [&](T& n) {
                    auto val = static_cast<T>(std::abs(dist(gen) * dist(gen)));
                    n = val ? val : 1;
                    });
            #elif defined(_OPENMP)
                #pragma omp parallel for schedule(guided)
                for (int i = 0; i < this->size(); ++i) {
                    auto val = std::abs(static_cast<T>(dist(gen) * dist(gen)));
                    this->at(i) = val ? val : 1;
                }
            #else
                std::for_each(this->begin(), this->end(), [&](T& n) {
                    auto val = std::abs(static_cast<T>(dist(gen) * dist(gen)));
                    n = val ? val : 1;
                    });
            #endif
        }

        #if defined(USE_CUDA)
        auto generate_random_list_cuda(int max = 8, int float_shift = 100)
        {
            user_space::generate_random_number(this->data(), this->size(), std::pow(10, float_shift), max);
        }
        #endif

        auto copy(vector_ext<T>& dest)
        {
            size_check(*this, dest);

            #if !defined(NO_EXEC) && !defined(_OPENMP)
            std::copy(std::execution::par, this->begin(), this->end(), dest.begin());
            #elif defined(_OPENMP)
            #pragma omp parallel for schedule(guided)
            for (int i = 0; i < this->size(); ++i)
            {
                dest.at(i) = this->at(i);
            }
            #else
            std::copy(this->begin(), this->end(), dest.begin());
            #endif
        }
    }; // class vector_ext
} // namespace std
