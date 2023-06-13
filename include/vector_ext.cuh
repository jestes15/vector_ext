#ifndef VECTOR_EXT_HPP
#define VECTOR_EXT_HPP

#include <cmath>
#include <functional>
#include <iostream>
#include <iterator>
#include <limits>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>

#include "types.cuh"

#if defined(USE_EXECUTION_POLICY)
#include <execution>
#endif

#if defined(USE_CUDA)
#include "kernel_impl.cuh"
#endif

namespace std_vec
{
template <typename Type_> class vector_ext : public std::vector<Type_>
{
  private:
    /* Calculates the depth limit given the size of a vector
     * Usage: depth_limit(n) where n is the size of the vector
     */
    auto depth_limit(const i64 size)
    {
        return static_cast<i64>(2 * floor(log2(static_cast<f64>(size))));
    }

    /* Swaps a and b
     * Usage: swap(*i, *j) where i and j are two variables
     */
    auto swap(Type_ &a, Type_ &b)
    {
        auto temp = std::move(a);
        a = std::move(b);
        b = std::move(temp);
    }

    /* Finds the partition index for quick sort
     * Usage: partition_iterator(std::begin(vector), std::end(vector), std::less<>())
     */
    template <typename Iter_, typename Compare> auto partition_iterator(Iter_ first, Iter_ last, Compare comp)
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
    template <typename Iter_, typename Compare> auto _quick_sort(Iter_ first, Iter_ last, Compare comp) -> void
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
    template <typename Iter_, typename Compare, typename buff>
    void mergesortInternal(const Iter_ first, const Iter_ last, const Compare comp, const buff firstMerge)
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
    template <typename Iter_, class Compare> inline auto _heap_sort(Iter_ first, Iter_ last, const Compare comp)
    {
        std::make_heap(first, last, comp);
        for (; last - first >= 2; last--)
            std::pop_heap(first, last, comp);
    }

    /* Driver for insertion sort
     * Usage: _insertion_sort(std::begin(vector), std::end(vector), std::less<>())
     */
    template <typename Iter_, typename Compare> auto _insertion_sort(Iter_ begin, Iter_ end, const Compare comp)
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

    template <typename Iter_, typename Compare>
    void _introspective_sort(Iter_ begin, Iter_ end, const Compare comp, i64 max_depth)
    {
        auto size = std::distance(begin, end);
        constexpr auto insertion_sort_max_val = 16;

        if (size < insertion_sort_max_val)
            _insertion_sort(begin, end, comp);

        else if (max_depth == 0)
            _heap_sort(begin, end, comp);

        else
        {
            auto partition = partition_iterator(begin, end, comp);
            _introspective_sort(begin, partition - 1, comp, max_depth - 1);
            _introspective_sort(partition, end, comp, max_depth - 1);
        }
    }

  protected:
    static auto resize_check(const i64 n)
    {
        if (n < 0)
        {
            std::string err = "vector_ext::resize_check: resize request failed due to an invalid request";
            throw std::domain_error(err);
        }
    }
    auto range_check(const i64 n) const
    {
        if (static_cast<unsigned long long>(abs(n)) >= this->size())
        {
            const std::string err = "vector_ext::range_check: n >= this->size()";
            throw std::out_of_range(err);
        }
    }
    static auto const_range_check(const i64 n, const i64 size)
    {
        if (std::abs(n) >= size)
        {
            const std::string err = "vector_ext::range_check: n >= size";
            throw std::out_of_range(err);
        }
    }
    static auto const_pure_val_range_check(const i64 n, const i64 size)
    {
        if (n >= size)
        {
            const std::string err = "vector_ext::range_check: n >= size";
            throw std::out_of_range(err);
        }
    }
    static auto nothrow_const_range_check(const i64 n, const i64 size) noexcept
    {
        if (std::abs(n) >= size)
            return false;
        return true;
    }
    static auto nothrow_pure_val_range_check(const i64 n, const i64 size) noexcept
    {
        if (n >= size)
            return false;
        return true;
    }
    auto range_check_plus_one(const i64 n) const
    {
        if (static_cast<long int>(std::abs(n)) >= static_cast<long int>(this->size()) + 1)
        {
            const std::string err = "vector_ext::range_check_plus_one: n >= this->size() + 1";
            throw std::out_of_range(err);
        }
    }
    [[nodiscard]] auto get_true_place(const i64 n) const noexcept
    {
        if (std::abs(n) == n)
            return n;
        return static_cast<int>(this->size()) + n;
    }
    static auto size_check(vector_ext<Type_> &vec1, vector_ext<Type_> &vec2)
    {
        if (vec1.size() != vec2.size())
        {
            const std::string err = "vector_ext::size_check: vec1.size() != vec2.size()";
            throw std::range_error(err);
        }
    }

  public:
    // Specialization
    using std::vector<Type_>::vector;

    // Member Functions
    using std::vector<Type_>::operator=;
    using std::vector<Type_>::assign;
    using std::vector<Type_>::get_allocator;

    // Element Access
    using std::vector<Type_>::operator[];
    using std::vector<Type_>::front;
    using std::vector<Type_>::back;
    using std::vector<Type_>::data;

    // Iterators
    using std::vector<Type_>::begin;
    using std::vector<Type_>::cbegin;
    using std::vector<Type_>::end;
    using std::vector<Type_>::cend;
    using std::vector<Type_>::rbegin;
    using std::vector<Type_>::crbegin;
    using std::vector<Type_>::rend;
    using std::vector<Type_>::crend;

    // Capacity
    using std::vector<Type_>::empty;
    using std::vector<Type_>::size;
    using std::vector<Type_>::max_size;
    using std::vector<Type_>::reserve;
    using std::vector<Type_>::capacity;
    using std::vector<Type_>::shrink_to_fit;

    // Modifiers
    using std::vector<Type_>::clear;
    using std::vector<Type_>::insert;
    using std::vector<Type_>::emplace;
    using std::vector<Type_>::erase;
    using std::vector<Type_>::push_back;
    using std::vector<Type_>::emplace_back;
    using std::vector<Type_>::pop_back;
    using std::vector<Type_>::resize;
    using std::vector<Type_>::swap;

    auto at(const long long n) -> Type_ &
    {
        range_check(n);
        auto num = get_true_place(n);
        return (*this)[num];
    }

    auto operator+(vector_ext<Type_> &vector_obj) -> vector_ext<Type_>
    {
        size_check(*this, vector_obj);
        vector_ext<Type_> ret_vec(this->size());

#if defined(USE_EXECUTION_POLICY)
        std::transform(std::execution::par_unseq, this->begin(), this->end(), vector_obj.begin(), ret_vec.begin(),
                       [](Type_ &a, Type_ &b) { return a + b; });
#elif defined(USE_CUDA)
        user_space::add(ret_vec, *this, vector_obj);
#else
#pragma omp parallel for schedule(guided)
        for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
            ret_vec.at(i) = this->at(i) + vector_obj.at(i);
#endif

        return ret_vec;
    }
    auto operator-(vector_ext<Type_> &vector_obj) -> vector_ext<Type_>
    {
        size_check(*this, vector_obj);
        vector_ext<Type_> ret_vec(this->size());

#if defined(USE_EXECUTION_POLICY)
        std::transform(std::execution::par_unseq, this->begin(), this->end(), vector_obj.begin(), ret_vec.begin(),
                       [](Type_ &a, Type_ &b) { return a - b; });
#elif defined(USE_CUDA)
        user_space::sub(ret_vec, *this, vector_obj);
#else
#pragma omp parallel for schedule(guided)
        for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
            ret_vec.at(i) = this->at(i) - vector_obj.at(i);
#endif

        return ret_vec;
    }
    auto operator*(vector_ext<Type_> &vector_obj) -> vector_ext<Type_>
    {
        size_check(*this, vector_obj);
        vector_ext<Type_> ret_vec(this->size());

#if defined(USE_EXECUTION_POLICY)
        std::transform(std::execution::par_unseq, this->begin(), this->end(), vector_obj.begin(), ret_vec.begin(),
                       [](Type_ &a, Type_ &b) { return a * b; });
#elif defined(USE_CUDA)
        user_space::mul(ret_vec, *this, vector_obj);
#else
#pragma omp parallel for schedule(guided)
        for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
            ret_vec.at(i) = this->at(i) * vector_obj.at(i);
#endif

        return ret_vec;
    }
    auto operator/(vector_ext<Type_> &vector_obj) -> vector_ext<Type_>
    {
        for (auto &i : vector_obj)
            if (i == 0)
                throw std::range_error("vector_ext::operator/: vector_obj has 0");

        size_check(*this, vector_obj);
        vector_ext<Type_> ret_vec(this->size());
#if defined(USE_EXECUTION_POLICY)
        std::transform(std::execution::par_unseq, this->begin(), this->end(), vector_obj.begin(), ret_vec.begin(),
                       [](Type_ &a, Type_ &b) { return a / b; });
#elif defined(USE_CUDA)
        user_space::div(ret_vec, *this, vector_obj);
#else
#pragma omp parallel for schedule(guided)
        for (auto i = 0; i < static_cast<int>(ret_vec.size()); i++)
            ret_vec.at(i) = this->at(i) / vector_obj.at(i);
#endif

        return ret_vec;
    }

    auto operator++() -> vector_ext<Type_>
    {
        auto copy = *this;
        vector_ext<Type_> new_array(this->size() + 1);
        new_array.at(0) = 0;

#pragma omp parallel for schedule(guided)
        for (long long i = 1; (i - 1) < this->size(); ++i)
            new_array.at(i) = this->at(i - 1);
        *this = new_array;
        return copy;
    }
    auto operator++(int) -> vector_ext<Type_> &
    {
        this->emplace_back(0);
        return *this;
    }

    auto operator--() -> Type_
    {
        auto val = this->at(0);
        vector_ext<Type_> new_array(this->size() - 1);

#pragma omp parallel for schedule(guided)
        for (long long i = 1; i < this->size(); ++i)
            new_array.at(i - 1) = this->at(i);
        *this = std::move(new_array);
        return val;
    }
    auto operator--(int) -> Type_
    {
        Type_ val = this->at(-1);
        this->resize(this->size() - 1);
        return val;
    }

    template <typename Compare> auto quick_sort(Compare comp) -> void
    {
        _quick_sort(this->begin(), this->end(), comp);
    }
    auto quick_sort() -> void
    {
        _quick_sort(this->begin(), this->end(), std::less<>{});
    }

    template <typename Compare> auto merge_sort(const Compare comp)
    {
        vector_ext<Type_> mergeSpace(this->end() - this->begin());
        mergesortInternal(this->begin(), this->end(), comp, mergeSpace.begin());
    }
    auto merge_sort()
    {
        vector_ext<Type_> mergeSpace(this->end() - this->begin());
        mergesortInternal(this->begin(), this->end(), std::less<>{}, mergeSpace.begin());
    }

    template <typename Compare> auto heap_sort(const Compare comp)
    {
        _heap_sort(this->begin(), this->end(), comp);
    }
    auto heap_sort()
    {
        _heap_sort(this->begin(), this->end(), std::less<>{});
    }

    template <typename Compare> auto insertion_sort(const Compare comp)
    {
        _insertion_sort(this->begin(), this->end(), comp);
    }
    auto insertion_sort()
    {
        _insertion_sort(this->begin(), this->end(), std::less<>{});
    }

    template <typename Compare> auto sort(const Compare comp)
    {
        i64 max_depth = depth_limit(this->size());
        _introspective_sort(this->begin(), this->end(), comp, max_depth);
    }
    auto sort()
    {
        i64 max_depth = depth_limit(this->size());
        _introspective_sort(this->begin(), this->end(), std::less<>(), max_depth);
    }

    template <typename Function_> auto generate_random_list_lam(const Function_ &function)
    {
#if defined(USE_EXECUTION_POLICY)
        std::for_each(std::execution::par, this->begin(), this->end(), function);
#elif defined(USE_OPENMP)
#pragma omp parallel for schedule(guided)
        for (i32 i = 0; i < this->size(); ++i)
        {
            function(this->at(i));
        }
#else
        for (auto &i : *this)
            function(i);
#endif
    }
    auto generate_random_list_resize(const i64 length, const i32 ax0 = -300, const i32 bx0 = 300)
    {
        resize_check(length);
        this->resize(length);

        std::random_device gen;
        std::uniform_int_distribution<int> dist(ax0, bx0);

#if defined(USE_EXECUTION_POLICY)
        std::for_each(std::execution::par, this->begin(), this->end(), [&](Type_ &n) {
            auto val = static_cast<Type_>(dist(gen) * dist(gen));
            n = val ? val : 1;
        });
#elif defined(USE_OPENMP)
#pragma omp parallel for schedule(guided)
        for (i32 i = 0; i < this->size(); ++i)
        {
            auto temp = static_cast<Type_>(dist(gen) * dist(gen));
            this->at(i) = (temp) ? temp : 1;
        }
#else
        std::for_each(this->begin(), this->end(), [&](Type_ &n) {
            auto val = static_cast<Type_>(dist(gen) * dist(gen));
            n = val ? val : 1;
        });
#endif
    }
    auto generate_random_list(const i32 ax0 = -300, const i32 bx0 = 300)
    {
        std::random_device gen;
        std::uniform_int_distribution<int> dist(ax0, bx0);

#if defined(USE_EXECUTION_POLICY)
        std::for_each(std::execution::par, this->begin(), this->end(), [&](Type_ &n) {
            auto val = static_cast<Type_>(dist(gen) * dist(gen));
            n = val ? val : 1;
        });
#elif defined(USE_OPENMP)
#pragma omp parallel for schedule(guided)
        for (i32 i = 0; i < this->size(); ++i)
        {
            auto val = static_cast<Type_>(dist(gen) * dist(gen));
            this->at(i) = val ? val : 1;
        }
#else
        std::for_each(this->begin(), this->end(), [&](Type_ &n) {
            auto val = static_cast<Type_>(dist(gen) * dist(gen));
            n = val ? val : 1;
        });
#endif
    }
    auto generate_positive_random_list(const i32 ax0 = -300, const i32 bx0 = 300)
    {
        std::random_device gen;
        std::uniform_int_distribution<int> dist(ax0, bx0);

#if defined(USE_EXECUTION_POLICY)
        std::for_each(std::execution::par, this->begin(), this->end(), [&](Type_ &n) {
            auto val = static_cast<Type_>(std::abs(dist(gen) * dist(gen)));
            n = val ? val : 1;
        });
#elif defined(USE_OPENMP)
#pragma omp parallel for schedule(guided)
        for (i32 i = 0; i < this->size(); ++i)
        {
            auto val = std::abs(static_cast<Type_>(dist(gen) * dist(gen)));
            this->at(i) = val ? val : 1;
        }
#else
        std::for_each(this->begin(), this->end(), [&](Type_ &n) {
            auto val = std::abs(static_cast<Type_>(dist(gen) * dist(gen)));
            n = val ? val : 1;
        });
#endif
    }

#if defined(USE_CUDA)
    auto generate_random_list_cuda(i32 max = 8, i32 float_shift = 100)
    {
        user_space::generate_random_number(this->data(), this->size(), std::pow(10, float_shift), max);
    }
#endif

    auto copy(vector_ext<Type_> &dest)
    {
        size_check(*this, dest);

#if defined(USE_EXECUTION_POLICY)
        std::copy(std::execution::par, this->begin(), this->end(), dest.begin());
#elif defined(USE_OPENMP)
#pragma omp parallel for schedule(guided)
        for (i32 i = 0; i < this->size(); ++i)
        {
            dest.at(i) = this->at(i);
        }
#else
        std::copy(this->begin(), this->end(), dest.begin());
#endif
    }
}; // class vector_ext
} // namespace std_vec

#endif // VECTOR_EXT_HPP