#include <array>
#include <iostream>
#include <optional>

enum quaternion_interpolation_method {
    slerp,
    lerp,
    nlerp
};

template <typename T> struct unit_vector
{
    T i_coeff, j_coeff, z_coeff;
};

class quaternion
{
  public:
    // Default Constructor
    quaternion() : q0(0.0), q1(0.0), q2(0.0), q3(0.0)
    {
    }

    // Constructor with 1 to 4 arguments
    template <typename T> quaternion(T q0, T q1, T q2, T q3) : q0(q0), q1(q1), q2(q2), q3(q3)
    {
    }
    template <typename T> quaternion(T q0, T q1, T q2) : q0(q0), q1(q1), q2(q2), q3(static_cast<T>(0))
    {
    }
    template <typename T> quaternion(T q0, T q1) : q0(q0), q1(q1), q2(static_cast<T>(0)), q3(static_cast<T>(0))
    {
    }
    template <typename T> quaternion(T q0) : q0(q0), q1(static_cast<T>(0)), q2(static_cast<T>(0)), q3(static_cast<T>(0))
    {
    }

    // Unit Vector Constructors
    template <typename T>
    quaternion(T q0, struct unit_vector<T> v) : q0(q0), q1(v.i_coeff), q2(v.j_coeff), q3(v.z_coeff)
    {
    }
    template <typename T>
    quaternion(struct unit_vector<T> v) : q0(static_cast<T>(0)), q1(v.i_coeff), q2(v.j_coeff), q3(v.z_coeff)
    {
    }

    // C Style Array Constructors
    template <typename T> quaternion(T q0, T v[3]) : q0(q0), q1(v[0]), q2(v[1]), q3(v[2])
    {
    }
    template <typename T> quaternion(T v[3]) : q0(static_cast<T>(0)), q1(v[0]), q2(v[1]), q3(v[2])
    {
    }

    // std::array Constructors
    template <typename T> quaternion(T q0, std::array<T, 3UL> v) : q0(q0), q1(v.at(0)), q2(v.at(1)), q3(v.at(2))
    {
    }
    template <typename T> quaternion(std::array<T, 3UL> v) : q0(static_cast<T>(0)), q1(v.at(0)), q2(v.at(1)), q3(v.at(2))
    {
    }
    template <typename T> quaternion(std::array<T, 4UL> v) : q0(v.at(0)), q1(v.at(1)), q2(v.at(2)), q3(v.at(3))
    {
    }

    // Get methods
    double get_a() const
    {
        return q0;
    }
    double get_b() const
    {
        return q1;
    }
    double get_c() const
    {
        return q2;
    }
    double get_d() const
    {
        return q3;
    }

    // Set methods
    template <typename T> void set_a(T q0)
    {
        this->q0 = q0;
    }
    template <typename T> void set_b(T q1)
    {
        this->q1 = q1;
    }
    template <typename T> void set_c(T q2)
    {
        this->q2 = q2;
    }
    template <typename T> void set_d(T q3)
    {
        this->q3 = q3;
    }

    double norm() const
    {
        return std::sqrt(std::pow(this->q0, 2) + std::pow(this->q1, 2) + std::pow(this->q2, 2) + std::pow(this->q3, 2));
    }

    quaternion inverse() const
    {
        double fractional_component = static_cast<double>(std::pow(q0, 2) + std::pow(q1, 2) + std::pow(q2, 2) + std::pow(q3, 2));
        return quaternion(q0 * (1.0 / fractional_component), -q1 * (1.0 / fractional_component),
                          -q2 * (1.0 / fractional_component), -q3 * (1.0 / fractional_component));
    }

    quaternion normalize() const {
        return quaternion(q0 / norm(), q1 / norm(), q2 / norm(), q3 / norm());
    }

    quaternion complex_conjugate() const
    {
        return quaternion(q0, -q1, -q2, -q3);
    }

    std::optional<quaternion> interpolate(quaternion &q, quaternion_interpolation_method method, double t) const noexcept
    {
        if (method == quaternion_interpolation_method::slerp)
        {
            return slerp(q, t);
        }
        else if (method == quaternion_interpolation_method::lerp)
        {
            return lerp(q, t);
        }
        else if (method == quaternion_interpolation_method::nlerp)
        {
            return nlerp(q, t);
        }
        else
        {
            return {};
        }
    }

    quaternion slerp(quaternion &q, double &t) const
    {
        double cos_theta = q.q0 * this->q0 + q.q1 * this->q1 + q.q2 * this->q2 + q.q3 * this->q3;
        double theta = std::acos(cos_theta);
        double sin_theta = std::sin(theta);
        double w1 = std::sin((1.0 - t) * theta) / sin_theta;
        double w2 = std::sin(t * theta) / sin_theta;
        return quaternion(w1 * q.q0 + w2 * this->q0, w1 * q.q1 + w2 * this->q1, w1 * q.q2 + w2 * this->q2,
                          w1 * q.q3 + w2 * this->q3);
    }

    quaternion lerp(quaternion &q, double &t) const
    {
        return quaternion((1.0 - t) * q.q0 + t * this->q0, (1.0 - t) * q.q1 + t * this->q1, (1.0 - t) * q.q2 + t * this->q2,
                          (1.0 - t) * q.q3 + t * this->q3);
    }

    quaternion nlerp(quaternion &q, double &t) const
    {
        return lerp(q, t).normalize();
    }

    // Quaternion Output Stream
    friend std::ostream &operator<<(std::ostream &os, const quaternion &q)
    {
        os << "(" << q.q0 << " + " << q.q1 << "i + " << q.q2 << "j + " << q.q3 << "k)";
        return os;
    }

  private:
    double q0, q1, q2, q3;
};

// Quaternion Equality Operator
bool operator==(const quaternion &q, const quaternion &s)
{
    return (q.get_a() == s.get_a() && q.get_b() == s.get_b() && q.get_c() == s.get_c() && q.get_d() == s.get_d());
}

// Quaternion Inequality Operator
template <typename T> bool operator!=(const quaternion &q, const quaternion &s)
{
    return !(s == q);
}

// Addition operators
quaternion operator+(const quaternion &q, const quaternion &s)
{
    return quaternion(q.get_a() + s.get_a(), q.get_b() + s.get_b(), q.get_c() + s.get_c(), q.get_d() + s.get_d());
}

// Subtraction operators
quaternion operator-(const quaternion &q, const quaternion &s)
{
    return quaternion(q.get_a() - s.get_a(), q.get_b() - s.get_b(), q.get_c() - s.get_c(), q.get_d() - s.get_d());
}

// Multiplication operators
quaternion operator*(const quaternion &q, const quaternion &s)
{
    return quaternion(q.get_a() * s.get_a() - q.get_b() * s.get_b() - q.get_c() * s.get_c() - q.get_d() * s.get_d(),
                      q.get_a() * s.get_b() + q.get_b() * s.get_a() + q.get_c() * s.get_d() - q.get_d() * s.get_c(),
                      q.get_a() * s.get_c() - q.get_b() * s.get_d() + q.get_c() * s.get_a() + q.get_d() * s.get_b(),
                      q.get_a() * s.get_d() + q.get_b() * s.get_c() - q.get_c() * s.get_b() + q.get_d() * s.get_a());
}

template <typename T> quaternion operator*(const quaternion &q, const T &s)
{
    return quaternion(q.get_a() * s, q.get_b() * s, q.get_c() * s, q.get_d() * s);
}

template <typename T> quaternion operator*(const T &s, const quaternion &q)
{
    return quaternion(q.get_a() * s, q.get_b() * s, q.get_c() * s, q.get_d() * s);
}

// Division operators
quaternion operator/(const quaternion &q, const quaternion &s)
{
    double denominator =
        std::pow(s.get_a(), 2) + std::pow(s.get_b(), 2) + std::pow(s.get_c(), 2) + std::pow(s.get_d(), 2);
    double t0 =
        (s.get_a() * q.get_a() + s.get_b() * q.get_b() + s.get_c() * q.get_c() + s.get_d() * q.get_d()) / denominator;
    double t1 =
        (s.get_a() * q.get_b() - s.get_b() * q.get_a() - s.get_c() * q.get_d() + s.get_d() * q.get_c()) / denominator;
    double t2 =
        (s.get_a() * q.get_c() + s.get_b() * q.get_d() - s.get_c() * q.get_a() - s.get_d() * q.get_b()) / denominator;
    double t3 =
        (s.get_a() * q.get_d() - s.get_b() * q.get_c() + s.get_c() * q.get_b() - s.get_d() * q.get_a()) / denominator;

    return quaternion(t0, t1, t2, t3);
}

template <typename T> quaternion operator/(const quaternion &q, const T &s)
{
    return quaternion(q.get_a() / s, q.get_b() / s, q.get_c() / s, q.get_d() / s);
}

template <typename T> quaternion operator/(const T &s, const quaternion &q)
{
    return quaternion(q.get_a() / s, q.get_b() / s, q.get_c() / s, q.get_d() / s);
}

// Quaternion Comparison Operators
bool operator<(const quaternion &q, const quaternion &s)
{
    return (q.get_a() < s.get_a() && q.get_b() < s.get_b() && q.get_c() < s.get_c() && q.get_d() < s.get_d());
}

bool operator>(const quaternion &q, const quaternion &s)
{
    return (q.get_a() > s.get_a() && q.get_b() > s.get_b() && q.get_c() > s.get_c() && q.get_d() > s.get_d());
}

bool operator<=(const quaternion &q, const quaternion &s)
{
    return (q.get_a() <= s.get_a() && q.get_b() <= s.get_b() && q.get_c() <= s.get_c() && q.get_d() <= s.get_d());
}

bool operator>=(const quaternion &q, const quaternion &s)
{
    return (q.get_a() >= s.get_a() && q.get_b() >= s.get_b() && q.get_c() >= s.get_c() && q.get_d() >= s.get_d());
}

// Quaternion Unary Operators
quaternion operator-(const quaternion &q)
{
    return quaternion(-q.get_a(), -q.get_b(), -q.get_c(), -q.get_d());
}

// Quaternion Absolute Value
quaternion abs(const quaternion &q)
{
    return quaternion(std::abs(q.get_a()), std::abs(q.get_b()), std::abs(q.get_c()), std::abs(q.get_d()));
}