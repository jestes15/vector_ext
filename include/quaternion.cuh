#include <array>
#include <iomanip>
#include <iostream>
#include <optional>

#include "types.cuh"

enum quaternion_interpolation_method
{
    slerp,
    lerp,
    nlerp
};

template <typename _Type> struct unit_vector
{
    _Type i_coeff, j_coeff, z_coeff;
};

class quaternion
{
  public:
    // Default Constructor
    quaternion() : q0(0.0), q1(0.0), q2(0.0), q3(0.0)
    {
    }

    // Constructor with 1 to 4 arguments
    template <typename _Type> quaternion(_Type q0, _Type q1, _Type q2, _Type q3) : q0(q0), q1(q1), q2(q2), q3(q3)
    {
    }
    template <typename _Type>
    quaternion(_Type q0, _Type q1, _Type q2) : q0(q0), q1(q1), q2(q2), q3(static_cast<_Type>(0))
    {
    }
    template <typename _Type>
    quaternion(_Type q0, _Type q1) : q0(q0), q1(q1), q2(static_cast<_Type>(0)), q3(static_cast<_Type>(0))
    {
    }
    template <typename _Type>
    quaternion(_Type q0) : q0(q0), q1(static_cast<_Type>(0)), q2(static_cast<_Type>(0)), q3(static_cast<_Type>(0))
    {
    }

    // Unit Vector Constructors
    template <typename _Type>
    quaternion(_Type q0, struct unit_vector<_Type> v) : q0(q0), q1(v.i_coeff), q2(v.j_coeff), q3(v.z_coeff)
    {
    }
    template <typename _Type>
    quaternion(struct unit_vector<_Type> v) : q0(static_cast<_Type>(0)), q1(v.i_coeff), q2(v.j_coeff), q3(v.z_coeff)
    {
    }

    // C Style Array Constructors
    template <typename _Type> quaternion(_Type q0, _Type v[3]) : q0(q0), q1(v[0]), q2(v[1]), q3(v[2])
    {
    }
    template <typename _Type> quaternion(_Type v[3]) : q0(static_cast<_Type>(0)), q1(v[0]), q2(v[1]), q3(v[2])
    {
    }

    // std::array Constructors
    template <typename _Type>
    quaternion(_Type q0, std::array<_Type, 3UL> v) : q0(q0), q1(v.at(0)), q2(v.at(1)), q3(v.at(2))
    {
    }
    template <typename _Type>
    quaternion(std::array<_Type, 3UL> v) : q0(static_cast<_Type>(0)), q1(v.at(0)), q2(v.at(1)), q3(v.at(2))
    {
    }
    template <typename _Type> quaternion(std::array<_Type, 4UL> v) : q0(v.at(0)), q1(v.at(1)), q2(v.at(2)), q3(v.at(3))
    {
    }

    // Get methods
    f64 get_a() const
    {
        return q0;
    }
    f64 get_b() const
    {
        return q1;
    }
    f64 get_c() const
    {
        return q2;
    }
    f64 get_d() const
    {
        return q3;
    }

    // Set methods
    template <typename _Type> void set_a(const _Type q0) const
    {
        this->q0 = q0;
    }
    template <typename _Type> void set_b(const _Type q1) const
    {
        this->q1 = q1;
    }
    template <typename _Type> void set_c(const _Type q2) const
    {
        this->q2 = q2;
    }
    template <typename _Type> void set_d(const _Type q3) const
    {
        this->q3 = q3;
    }

    // Quaternion Equality Operator
    bool operator==(const quaternion &s) const
    {
        return (q0 == s.get_a() && q1 == s.get_b() && q2 == s.get_c() && q3 == s.get_d());
    }

    // Quaternion Inequality Operator
    bool operator!=(const quaternion &s) const
    {
        return !(s == *this);
    }

    // Addition operators
    quaternion operator+(const quaternion &s) const
    {
        return quaternion(q0 + s.get_a(), q1 + s.get_b(), q2 + s.get_c(), q3 + s.get_d());
    }

    // Subtraction operators
    quaternion operator-(const quaternion &s) const
    {
        return quaternion(q0 - s.get_a(), q1 - s.get_b(), q2 - s.get_c(), q3 - s.get_d());
    }

    // Quaternion Unary Operators
    quaternion operator-()
    {
        return quaternion(-q0, -q1, -q2, -q3);
    }

    // Multiplication operators
    quaternion operator*(const quaternion &s) const
    {
        f64 r0 = s.get_a(), r1 = s.get_b(), r2 = s.get_c(), r3 = s.get_d();

        return quaternion(q0 * r0 - q1 * r1 - q2 * r2 - q3 * r3, q0 * r1 + q1 * r0 + q2 * r3 - q3 * r2,
                          q0 * r2 - q1 * r3 + q2 * r0 + q3 * r1, q0 * r3 + q1 * r2 - q2 * r1 + q3 * r0);
    }

    template <typename _Type> quaternion operator*(const _Type &s) const
    {
        return quaternion(q0 * s, q1 * s, q2 * s, q3 * s);
    }

    // Division operators
    quaternion operator/(const quaternion &s) const
    {
        f64 r0 = s.get_a(), r1 = s.get_b(), r2 = s.get_c(), r3 = s.get_d();

        f64 denominator = std::pow(r0, 2) + std::pow(r1, 2) + std::pow(r2, 2) + std::pow(r3, 2);
        f64 t0 = (r0 * q0 + r1 * q1 + r2 * q2 + r3 * q3) / denominator;
        f64 t1 = (r0 * q1 - r1 * q0 - r2 * q3 + r3 * q2) / denominator;
        f64 t2 = (r0 * q2 + r1 * q3 - r2 * q0 - r3 * q1) / denominator;
        f64 t3 = (r0 * q3 - r1 * q2 + r2 * q1 - r3 * q0) / denominator;

        return quaternion(t0, t1, t2, t3);
    }
    template <typename _Type> quaternion operator/(const _Type &s) const
    {
        return quaternion(q0 / s, q1 / s, q2 / s, q3 / s);
    }

    // Quaternion Comparison Operators
    bool operator<(const quaternion &s) const
    {
        return (q0 < s.get_a() && q1 < s.get_b() && q2 < s.get_c() && q3 < s.get_d());
    }
    bool operator>(const quaternion &s) const
    {
        return (q0 > s.get_a() && q1 > s.get_b() && q2 > s.get_c() && q3 > s.get_d());
    }
    bool operator<=(const quaternion &s) const
    {
        return (q0 <= s.get_a() && q1 <= s.get_b() && q2 <= s.get_c() && q3 <= s.get_d());
    }
    bool operator>=(const quaternion &s) const
    {
        return (q0 >= s.get_a() && q1 >= s.get_b() && q2 >= s.get_c() && q3 >= s.get_d());
    }

    f64 norm() const
    {
        return std::sqrt(std::pow(this->q0, 2) + std::pow(this->q1, 2) + std::pow(this->q2, 2) + std::pow(this->q3, 2));
    }

    quaternion inverse()
    {
        f64 fractional_component =
            static_cast<f64>(std::pow(q0, 2) + std::pow(q1, 2) + std::pow(q2, 2) + std::pow(q3, 2));
        return quaternion(q0 * (1.0 / fractional_component), -q1 * (1.0 / fractional_component),
                          -q2 * (1.0 / fractional_component), -q3 * (1.0 / fractional_component));
    }

    quaternion normalize()
    {
        return quaternion(q0 / norm(), q1 / norm(), q2 / norm(), q3 / norm());
    }

    quaternion complex_conjugate()
    {
        return quaternion(q0, -q1, -q2, -q3);
    }

    std::optional<quaternion> interpolate(const quaternion &q, quaternion_interpolation_method method, f64 t) noexcept
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

    quaternion ln() const
    {
        f64 norm = this->norm();
        f64 norm_of_imag = std::sqrt(std::pow(q1, 2) + std::pow(q2, 2) + std::pow(q3, 2));

        f64 real_part = std::log(norm);
        f64 imag_part_q1 = std::acos(q0 / norm) * q1 / norm_of_imag;
        f64 imag_part_q2 = std::acos(q0 / norm) * q2 / norm_of_imag;
        f64 imag_part_q3 = std::acos(q0 / norm) * q3 / norm_of_imag;
        return quaternion(real_part, imag_part_q1, imag_part_q2, imag_part_q3);
    }

    quaternion exp() const
    {
        f64 scalar = std::exp(q0);
        f64 norm_of_imag = std::sqrt(std::pow(q1, 2) + std::pow(q2, 2) + std::pow(q3, 2));

        f64 real_part = scalar * std::cos(norm_of_imag);
        f64 imag_part_q1 = scalar * q1 * std::sin(norm_of_imag) / norm_of_imag;
        f64 imag_part_q2 = scalar * q2 * std::sin(norm_of_imag) / norm_of_imag;
        f64 imag_part_q3 = scalar * q3 * std::sin(norm_of_imag) / norm_of_imag;

        return quaternion(real_part, imag_part_q1, imag_part_q2, imag_part_q3);
    }

    // Quaternion Exponentiation
    template <typename _Type> quaternion pow(const _Type &n) const
    {
        return (this->ln() * n).exp();
    }

    // Quaternion Absolute Value
    quaternion abs()
    {
        return quaternion(std::abs(q0), std::abs(q1), std::abs(q2), std::abs(q3));
    }

    // Quaternion Output Stream
    friend std::ostream &operator<<(std::ostream &os, const quaternion &q)
    {
        os << std::setprecision(13) << "(" << q.q0 << " + " << q.q1 << "i + " << q.q2 << "j + " << q.q3 << "k)"
           << std::setprecision(4);
        return os;
    }

  private:
    f64 q0, q1, q2, q3;

    quaternion slerp(const quaternion &q, const f64 &t)
    {
        f64 cos_theta = q.q0 * this->q0 + q.q1 * this->q1 + q.q2 * this->q2 + q.q3 * this->q3;
        f64 theta = std::acos(cos_theta);
        f64 sin_theta = std::sin(theta);
        f64 w1 = std::sin((1.0 - t) * theta) / sin_theta;
        f64 w2 = std::sin(t * theta) / sin_theta;
        return quaternion(w1 * q.q0 + w2 * this->q0, w1 * q.q1 + w2 * this->q1, w1 * q.q2 + w2 * this->q2,
                          w1 * q.q3 + w2 * this->q3);
    }

    quaternion lerp(const quaternion &q, const f64 &t)
    {
        return quaternion(((*this) * (1 - t)) + (q * t));
    }

    quaternion nlerp(const quaternion &q, const f64 &t)
    {
        return lerp(q, t).normalize();
    }
};