module;
#include <algorithm>
#include <cmath>
#include <functional>
#include <vector>
#include <type_traits>

export module algo;

namespace test_sort
{
    auto depth_limit(const long long size)
    {
        return static_cast<long long>(2 * floor(log(size)));
    }

    export auto swap(auto &a, auto &b)
    {
        auto temp = std::move(a);
        a = std::move(b);
        b = std::move(temp);
    }

    template <typename _Iter>
    auto partition(_Iter iter, const long long low, const long long high)
    {
        if constexpr (requires { iter.at(0); })
        {
            auto pivot = iter.at(high);
            auto i = low - 1;

            for (auto j = low; j < high; ++j)
            {
                if (iter.at(j) <= pivot)
                    swap(&iter.at(++i), &iter.at(j));
            }
            swap(&iter.at(i + 1), &iter.at(high));
            return i + 1;
        }
        else
        {
            auto pivot = iter[high];
            auto i = low - 1;

            for (auto j = low; j < high; ++j)
            {
                if (iter[j] <= pivot)
                    swap(&iter[++i], &iter[j]);
            }
            swap(&iter[i + 1], &iter[high]);
            return i + 1;
        }
    }

    template <typename _Iter>
    auto _quick_sort(_Iter iter, const long long low, const long long high) -> void
    {
        if (low < high)
        {
            const auto partition_index = partition(iter, low, high);

            _quick_sort(iter, low, partition_index - 1);
            _quick_sort(iter, partition_index + 1, high);
        }
    }

    export template <typename _Iter>
    auto quick_sort(_Iter iter, const int begin = 0, int end = -1)
    {
        if constexpr (requires { iter.size(); })
        {
            end = (end == -1) ? iter.size() - 1 : end;
            _quick_sort(iter, begin, end);
        }
        else
        {
            _quick_sort(iter, begin, end);
        }
    }

    template <typename _Iter>
    auto make_heap(_Iter iter, const long long size_of_heap, const long long root) -> void
    {
        auto largest = root;
        auto left = 2 * root + 1;
        auto right = 2 * root + 2;

        if constexpr (requires { iter.at(0); })
        {
            if (left < size_of_heap && iter.at(left) > iter.at(largest))
                largest = left;
            if (right < size_of_heap && iter.at(right) > iter.at(largest))
                largest = right;
            if (largest != root)
            {
                swap(&iter.at(root), &iter.at(largest));
                make_heap(iter, size_of_heap, largest);
            }
        }
        else
        {
            if (left < size_of_heap && iter[left] > iter[largest])
                largest = left;
            if (right < size_of_heap && iter[right] > iter[largest])
                largest = right;
            if (largest != root)
            {
                swap(&iter[root], &iter[largest]);
                make_heap(iter, size_of_heap, largest);
            }
        }
    }

    template <typename _Iter>
    auto _heap_sort(_Iter iter, const long long size)
    {
        for (auto i = size / 2 - 1; i >= 0; --i)
            make_heap(iter, size, i);

        if constexpr (requires { iter.at(0); })
        {
            for (auto i = size - 1; i > 0; --i)
            {
                swap(&iter.at(0), &iter.at(i));
                make_heap(iter, i, 0);
            }
        }
        else
        {
            for (auto i = size - 1; i > 0; --i)
            {
                swap(&iter[0], &iter[i]);
                make_heap(iter, i, 0);
            }
        }
    }

    export template <typename _Iter>
    auto heap_sort(_Iter iter, const long long size = -1)
    {
        if constexpr (requires { iter.size(); })
        {
            size = (size == -1) ? iter.size() : iter;
            _heap_sort(iter, size);
        }
        else
        {
            _heap_sort(iter, size);
        }
    }

    template <typename _Iter>
    auto merge(_Iter iter, const long long left, const long long mid, const long long right) -> void
    {
        const auto sub_array_one = mid - left + 1;
        const auto sub_array_two = right - mid;
        auto index_of_sub_array_one = 0LL, index_of_sub_array_two = 0LL, index_of_merged_array = left;

        if constexpr (requires { iter.at(0); })
        {
            std::vector<typename std::iterator_traits<_Iter>::value_type> left_array(sub_array_one, 0);
            std::vector<typename std::iterator_traits<_Iter>::value_type> right_array(sub_array_two, 0);

            for (auto i = 0; i < sub_array_one; i++)
                left_array.at(i) = iter.at(left + i);
            for (auto j = 0; j < sub_array_two; j++)
                right_array.at(j) = iter.at(mid + j + 1);

            while (index_of_sub_array_one < sub_array_one && index_of_sub_array_two < sub_array_two)
            {
                if (left_array.at(&index_of_sub_array_one) <= right_array.at(&index_of_sub_array_two))
                {
                    iter.at(index_of_merged_array) = left_array.at(&index_of_sub_array_one);
                    index_of_sub_array_one++;
                }
                else
                {
                    iter.at(index_of_merged_array) = right_array.at(&index_of_sub_array_two);
                    index_of_sub_array_two++;
                }
                ++index_of_merged_array;
            }
            while (index_of_sub_array_one < sub_array_one)
            {
                iter.at(index_of_merged_array) = left_array.at(&index_of_sub_array_one);
                ++index_of_sub_array_one;
                ++index_of_merged_array;
            }
            while (index_of_sub_array_two < sub_array_two)
            {
                iter.at(index_of_merged_array) = right_array.at(&index_of_sub_array_two);
                ++index_of_sub_array_two;
                ++index_of_merged_array;
            }
        }
        else
        {
            using arrElemType = typename std::remove_reference<decltype(*iter)>::type;

            std::vector<arrElemType> left_array(sub_array_one, 0);
            std::vector<arrElemType> right_array(sub_array_two, 0);

            for (auto i = 0; i < sub_array_one; i++)
                left_array.at(i) = iter[left + i];
            for (auto j = 0; j < sub_array_two; j++)
                right_array.at(j) = iter[mid + j + 1];

            while (index_of_sub_array_one < sub_array_one && index_of_sub_array_two < sub_array_two)
            {
                if (left_array.at(index_of_sub_array_one) <= right_array.at(index_of_sub_array_two))
                {
                    iter[index_of_merged_array] = left_array.at(index_of_sub_array_one);
                    index_of_sub_array_one++;
                }
                else
                {
                    iter[index_of_merged_array] = right_array.at(index_of_sub_array_two);
                    index_of_sub_array_two++;
                }
                ++index_of_merged_array;
            }
            while (index_of_sub_array_one < sub_array_one)
            {
                iter[index_of_merged_array] = left_array.at(index_of_sub_array_one);
                ++index_of_sub_array_one;
                ++index_of_merged_array;
            }
            while (index_of_sub_array_two < sub_array_two)
            {
                iter[index_of_merged_array] = right_array.at(index_of_sub_array_two);
                ++index_of_sub_array_two;
                ++index_of_merged_array;
            }
        }
    }

    export template <typename _Iter>
    auto merge_sort(_Iter iter, const long long begin = 0, const long long end = -1) -> void
    {
        if constexpr (requires { iter.size(); })
        {
            end = (end == -1) ? iter.size() : end;

            if (begin >= end)
                return;

            auto mid = begin + (end - begin) / 2;
            merge_sort(iter, begin, mid);
            merge_sort(iter, mid + 1, end);
            merge(iter, begin, mid, end);
        }
        else
        {
            if (begin >= end)
                return;

            auto mid = begin + (end - begin) / 2;
            merge_sort(iter, begin, mid);
            merge_sort(iter, mid + 1, end);
            merge(iter, begin, mid, end);
        }
    }

    export template <typename _Iter>
    auto insertion_sort(_Iter iter, const long long size)
    {
        if constexpr (requires { iter.at(0); })
        {
            for (auto i = 1; i < size; i++)
            {
                auto key = iter.at(i);
                auto j = i - 1;

                while (j >= 0 && iter.at(j) > key)
                {
                    iter.at(j + 1) = iter.at(j);
                    j = j - 1;
                }
                iter.at(j + 1) = key;
            }
        }
        else
        {
            for (auto i = 1; i < size; i++)
            {
                auto key = iter[i];
                auto j = i - 1;

                while (j >= 0 && iter[j] > key)
                {
                    iter[j + 1] = iter[j];
                    j = j - 1;
                }
                iter[j + 1] = key;
            }
        }
    }

    export template <typename _Iter>
    auto intro_sort(_Iter iter, const long long size)
    {
        constexpr auto insertion_sort_max_val = 16;

        if (size < insertion_sort_max_val)
            insertion_sort(iter, size);

        else if (depth_limit(size) == 0)
            _heap_sort(iter, size);

        else
            _quick_sort(iter, 0, size - 1);
    }

    export template <typename _Iter>
    auto sort(_Iter iter, int size = -1)
    {
        if constexpr (requires { iter.size(); })
        {
            if (size == -1)
                size = iter.size();
            intro_sort(iter, size);
        }
        else
        {
            intro_sort(iter, size);
        }
    }

    // Iterator Sort functions

    // Quick Sort
    template <typename _Iter, typename Compare>
    auto partition_iterator(_Iter first, _Iter last, Compare comp)
    {
        auto pivot = std::prev(last, 1);
        auto i = first;
        for (auto j = first; j != pivot; ++j)
        {
            if (comp(*j, *pivot))
            {
                swap(*i++, *j);
            }
        }
        swap(*i, *pivot);
        return i;
    }

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

    export template <typename _Iter>
    auto quick_sort(_Iter first, _Iter last) -> void
    {
        _quick_sort(first, last, std::less<>{});
    }

    export template <typename _Iter, typename Compare>
    auto quick_sort(_Iter first, _Iter last, Compare comp) -> void
    {
        _quick_sort(first, last, comp);
    }

    // Merge Sort
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

    export template <typename _Iter, typename Compare>
    void merge_sort(const _Iter first, const _Iter last, const Compare comp)
    {
        std::vector<typename std::iterator_traits<_Iter>::value_type> mergeSpace(last - first);

        mergesortInternal(first, last, comp, mergeSpace.begin());
    }

    export template <typename _Iter>
    void merge_sort(_Iter first, _Iter last)
    {
        std::vector<typename std::iterator_traits<_Iter>::value_type> mergeSpace(last - first);

        mergesortInternal(first, last, std::less<>{}, mergeSpace.begin());
    }

    // Heap Sort
    template <typename _Iter, class Compare>
    inline auto _heap_sort(_Iter first, _Iter last, const Compare comp)
    {
        std::make_heap(first, last, comp);
        for (; last - first >= 2; last--)
            std::pop_heap(first, last, comp);
    }

    export template <typename _Iter, class Compare>
    auto heap_sort(_Iter first, _Iter last, const Compare comp)
    {
        _heap_sort(first, last, comp);
    }

    export template <typename _Iter>
    auto heap_sort(_Iter first, _Iter last)
    {
        _heap_sort(first, last, std::less<>{});
    }

    // Insertion Sort
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
                {
                    break;
                }
            }
        }
    }

    export template <typename _Iter, typename Compare>
    auto insertion_sort(_Iter first, _Iter last, const Compare comp)
    {
        _insertion_sort(first, last, comp);
    }

    export template <typename _Iter>
    auto insertion_sort(_Iter first, _Iter last)
    {
        _insertion_sort(first, last, std::less<>{});
    }

    // Introspective Sort
    export template <typename _Iter>
    auto sort(_Iter begin, _Iter end)
    {
        auto size = std::distance(begin, end);
        constexpr auto insertion_sort_max_val = 16;

        if (size < insertion_sort_max_val)
            _insertion_sort(begin, end, std::less<>{});

        else if (depth_limit(size) == 0)
            _heap_sort(begin, end, std::less<>{});

        else
            _quick_sort(begin, end, std::less<>{});
    }

    export template <typename _Iter, typename Compare>
    auto sort(_Iter begin, _Iter end, Compare comp)
    {
        auto size = std::distance(begin, end);
        constexpr auto insertion_sort_max_val = 16;

        if (size < insertion_sort_max_val)
            _insertion_sort(begin, end, comp);

        else if (depth_limit(size) == 0)
            _heap_sort(begin, end, comp);

        else
            _quick_sort(begin, end, comp);
    }
}