#include <iostream>

// https://en.wikipedia.org/wiki/Quaternion
template <typename T> class quaternion
{
  public:
    quaternion(T a, T b, T c, T d) : a(a), b(b), c(c), d(d)
    {
    }
    quaternion() : a(static_cast<T>(0)), b(static_cast<T>(0)), c(static_cast<T>(0)), d(static_cast<T>(0))
    {
    }

    // Get methods
    T get_a() const
    {
        return a;
    }
    T get_b() const
    {
        return b;
    }
    T get_c() const
    {
        return c;
    }
    T get_d() const
    {
        return d;
    }
 
    // Set methods
    void set_a(T a)
    {
        this->a = a;
    }
    void set_b(T b)
    {
        this->b = b;
    }
    void set_c(T c)
    {
        this->c = c;
    }
    void set_d(T d)
    {
        this->d = d;
    }

    quaternion operator+(const quaternion &q) const
    {
        return quaternion(a + q.a, b + q.b, c + q.c, d + q.d);
    }
    quaternion operator-(const quaternion &q) const
    {
        return quaternion(a - q.a, b - q.b, c - q.c, d - q.d);
    }

    // Quaternion Output Stream
    friend std::ostream &operator<<(std::ostream &os, const quaternion &q)
    {
        os << "(" << q.a << " + " << q.b << "i + " << q.c << "j + " << q.d << "k)";
        return os;
    }

  private:
    T a, b, c, d;
};

template <typename T> quaternion<T> operator*(const quaternion<T> &q, const quaternion<T> &s)
{
    return quaternion(q.get_a() * s.get_a() - q.get_b() * s.get_b() - q.get_c() * s.get_c() - q.get_d() * s.get_d(),
                      q.get_a() * s.get_b() + q.get_b() * s.get_a() + q.get_c() * s.get_d() - q.get_d() * s.get_c(),
                      q.get_a() * s.get_c() - q.get_b() * s.get_d() + q.get_c() * s.get_a() + q.get_d() * s.get_b(),
                      q.get_a() * s.get_d() + q.get_b() * s.get_c() - q.get_c() * s.get_b() + q.get_d() * s.get_a());
}

template <typename T> quaternion<T> operator*(const quaternion<T> &q, const T &s)
{
    return quaternion<T>(q.get_a() * s, q.get_b() * s, q.get_c() * s, q.get_d() * s);
}

template <typename T> quaternion<T> operator*(const T &s, const quaternion<T> &q)
{
    return quaternion<T>(q.get_a() * s, q.get_b() * s, q.get_c() * s, q.get_d() * s);
}