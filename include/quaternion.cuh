#include <array>
#include <iostream>

template <typename T>
struct unit_vector {
    T i_coeff, j_coeff, z_coeff;
};

// https://en.wikipedia.org/wiki/Quaternion
template <typename T> class quaternion
{
  public:
    // Default Constructor
    quaternion() : q0(static_cast<T>(0)), q1(static_cast<T>(0)), q2(static_cast<T>(0)), q3(static_cast<T>(0))
    {
    }

    // Constructor with 1 to 4 arguments
    quaternion(T q0, T q1, T q2, T q3) : q0(q0), q1(q1), q2(q2), q3(q3)
    {
    }
    quaternion(T q0, T q1, T q2) : q0(q0), q1(q1), q2(q2), q3(static_cast<T>(0))
    {
    }
    quaternion(T q0, T q1) : q0(q0), q1(q1), q2(static_cast<T>(0)), q3(static_cast<T>(0))
    {
    }
    quaternion(T q0) : q0(q0), q1(static_cast<T>(0)), q2(static_cast<T>(0)), q3(static_cast<T>(0))
    {
    }

    // Unit Vector Constructors
    quaternion(T q0, unit_vector<T> v) : q0(q0), q1(v.i_coeff), q2(v.j_coeff), q3(v.z_coeff)
    {
    }
    quaternion(unit_vector<T> v) : q0(q0), q1(v.i_coeff), q2(v.j_coeff), q3(v.z_coeff)
    {
    }

    // C Style Array Constructors
    quaternion(T q0, T[3] v) : q0(q0), q1(v[0]), q2(v[1]), q3(v[2])
    {
    }
    quaternion(T[3] v) : q0(static_cast<T>(0)), q1(v[0]), q2(v[1]), q3(v[2])
    {
    }
    quaternion(T[4] v) : q0(v[0]), q1(v[1]), q2(v[2]), q3(v[3])
    {
    }

    // std::array Constructors
    quaternion(T q0, std::array<T, 3> v) : q0(q0), q1(v[0]), q2(v[1]), q3(v[2])
    {
    }
    quaternion(std::array<T, 3> v) : q0(static_cast<T>(0)), q1(v[0]), q2(v[1]), q3(v[2])
    {
    }
    quaternion(std::array<T, 4> v) : q0(v[0]), q1(v[1]), q2(v[2]), q3(v[3])
    {
    }


    // Get methods
    T get_a() const
    {
        return q0;
    }
    T get_b() const
    {
        return q1;
    }
    T get_c() const
    {
        return q2;
    }
    T get_d() const
    {
        return q3;
    }

    // Set methods
    void set_a(T q0)
    {
        this->q0 = q0;
    }
    void set_b(T q1)
    {
        this->q1 = q1;
    }
    void set_c(T q2)
    {
        this->q2 = q2;
    }
    void set_d(T q3)
    {
        this->q3 = q3;
    }

    T magnitude() const
    {
        return std::sqrt(std::pow(this->q0, 2) + std::pow(this->q1, 2) + std::pow(this->q2, 2) + std::pow(this->q3, 2));
    }

    quaternion inverse() const
    {
        double fractional_component =
            1.0 / static_cast<double>(std::pow(q0, 2) + std::pow(q1, 2) + std::pow(q2, 2) + std::pow(q3, 2));
        return fractional_component * quaternion(q0, -q1, -q2, -q3);
    }

    quaternion complex_conjugate() const {
        return quaternion(q0, -q1, -q2, -q3);
    }

    // Quaternion Equality Operator
    bool operator==(const quaternion &q) const
    {
        return (q0 == q.q0 && q1 == q.q1 && q2 == q.q2 && q3 == q.q3);
    }

    // Quaternion Inequality Operator
    bool operator!=(const quaternion &q) const
    {
        return !(*this == q);
    }    

    // Quaternion Output Stream
    friend std::ostream &operator<<(std::ostream &os, const quaternion &q)
    {
        os << "(" << q.q0 << " + " << q.q1 << "i + " << q.q2 << "j + " << q.q3 << "k)";
        return os;
    }

  private:
    T q0, q1, q2, q3;
};

// Addition operators
template <typename T> quaternion<T> operator+(const quaternion<T> &q, const quaternion<T> &s)
{
    return quaternion(q.get_a() + s.get_a(), q.get_b() + s.get_b(), q.get_c() + s.get_c(), q.get_d() + s.get_d());
}

// Subtraction operators
template <typename T> quaternion<T> operator-(const quaternion<T> &q, const quaternion<T> &s)
{
    return quaternion(q.get_a() - s.get_a(), q.get_b() - s.get_b(), q.get_c() - s.get_c(), q.get_d() - s.get_d());
}

// Multiplication operators
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