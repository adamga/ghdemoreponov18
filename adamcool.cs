using System;

internal static class AdamCoolMath
{
    /// <summary>
    /// Common math helpers (clamp/lerp/range mapping, number theory, and numeric utilities).
    /// </summary>
    /// <summary>
    /// Clamps <paramref name="value"/> between <paramref name="min"/> and <paramref name="max"/>.
    /// </summary>
    /// <param name="value">The value to clamp.</param>
    /// <param name="min">The inclusive lower bound.</param>
    /// <param name="max">The inclusive upper bound.</param>
    /// <returns>
    /// <paramref name="value"/> if it is within bounds; otherwise <paramref name="min"/> or <paramref name="max"/>.
    /// </returns>
    /// <exception cref="ArgumentException">Thrown when <paramref name="min"/> is greater than <paramref name="max"/>.</exception>
    public static int Clamp(int value, int min, int max)
    {
        if (min > max) throw new ArgumentException("min must be <= max.");
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }

    /// <summary>
    /// Clamps <paramref name="value"/> between <paramref name="min"/> and <paramref name="max"/>.
    /// </summary>
    /// <param name="value">The value to clamp.</param>
    /// <param name="min">The inclusive lower bound.</param>
    /// <param name="max">The inclusive upper bound.</param>
    /// <returns>
    /// <paramref name="value"/> if it is within bounds; otherwise <paramref name="min"/> or <paramref name="max"/>.
    /// </returns>
    /// <exception cref="ArgumentException">Thrown when <paramref name="min"/> is greater than <paramref name="max"/>.</exception>
    public static double Clamp(double value, double min, double max)
    {
        if (min > max) throw new ArgumentException("min must be <= max.");
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }

    /// <summary>
    /// Clamps <paramref name="value"/> between <paramref name="min"/> and <paramref name="max"/>.
    /// </summary>
    /// <typeparam name="T">A comparable type.</typeparam>
    /// <param name="value">The value to clamp.</param>
    /// <param name="min">The inclusive lower bound.</param>
    /// <param name="max">The inclusive upper bound.</param>
    /// <returns>
    /// <paramref name="value"/> if it is within bounds; otherwise <paramref name="min"/> or <paramref name="max"/>.
    /// </returns>
    /// <exception cref="ArgumentException">Thrown when <paramref name="min"/> is greater than <paramref name="max"/>.</exception>
    public static T Clamp<T>(T value, T min, T max) where T : IComparable<T>
    {
        if (min.CompareTo(max) > 0) throw new ArgumentException("min must be <= max.");
        if (value.CompareTo(min) < 0) return min;
        if (value.CompareTo(max) > 0) return max;
        return value;
    }

    /// <summary>
    /// Linear interpolation: returns a value between <paramref name="a"/> and <paramref name="b"/>.
    /// t is typically in [0, 1].
    /// </summary>
    /// <param name="a">The start value (t=0).</param>
    /// <param name="b">The end value (t=1).</param>
    /// <param name="t">Interpolation amount (commonly between 0 and 1, but not required).</param>
    /// <returns>The interpolated value.</returns>
    public static double Lerp(double a, double b, double t) => a + (b - a) * t;

    /// <summary>
    /// Maps <paramref name="value"/> from one range into another.
    /// </summary>
    /// <param name="value">The input value in the input range.</param>
    /// <param name="inMin">Input range minimum.</param>
    /// <param name="inMax">Input range maximum.</param>
    /// <param name="outMin">Output range minimum.</param>
    /// <param name="outMax">Output range maximum.</param>
    /// <returns>The mapped value in the output range.</returns>
    /// <exception cref="ArgumentException">Thrown when <paramref name="inMin"/> equals <paramref name="inMax"/>.</exception>
    public static double Map(double value, double inMin, double inMax, double outMin, double outMax)
    {
        if (inMin == inMax) throw new ArgumentException("Input range must not be zero.");
        var t = (value - inMin) / (inMax - inMin);
        return Lerp(outMin, outMax, t);
    }

    /// <summary>
    /// Maps <paramref name="value"/> from one range into another.
    /// Returns <see langword="false"/> when the input range is zero.
    /// </summary>
    /// <param name="value">The input value in the input range.</param>
    /// <param name="inMin">Input range minimum.</param>
    /// <param name="inMax">Input range maximum.</param>
    /// <param name="outMin">Output range minimum.</param>
    /// <param name="outMax">Output range maximum.</param>
    /// <param name="result">The mapped value in the output range (when successful).</param>
    /// <returns><see langword="true"/> if successful; otherwise <see langword="false"/>.</returns>
    public static bool TryMap(double value, double inMin, double inMax, double outMin, double outMax, out double result)
    {
        if (inMin == inMax)
        {
            result = 0;
            return false;
        }

        var t = (value - inMin) / (inMax - inMin);
        result = Lerp(outMin, outMax, t);
        return true;
    }

    /// <summary>
    /// True if the integer is even.
    /// </summary>
    /// <param name="value">The integer to check.</param>
    /// <returns><see langword="true"/> if even; otherwise <see langword="false"/>.</returns>
    public static bool IsEven(int value) => (value & 1) == 0;

    /// <summary>
    /// True if the integer is odd.
    /// </summary>
    /// <param name="value">The integer to check.</param>
    /// <returns><see langword="true"/> if odd; otherwise <see langword="false"/>.</returns>
    public static bool IsOdd(int value) => (value & 1) != 0;

    /// <summary>
    /// Greatest common divisor (non-negative).
    /// </summary>
    /// <param name="a">First value.</param>
    /// <param name="b">Second value.</param>
    /// <returns>The greatest common divisor of <paramref name="a"/> and <paramref name="b"/>.</returns>
    public static long Gcd(long a, long b)
    {
        a = Math.Abs(a);
        b = Math.Abs(b);
        while (b != 0)
        {
            var t = a % b;
            a = b;
            b = t;
        }
        return a;
    }

    /// <summary>
    /// Least common multiple (non-negative). Returns 0 if either input is 0.
    /// </summary>
    /// <param name="a">First value.</param>
    /// <param name="b">Second value.</param>
    /// <returns>The least common multiple of <paramref name="a"/> and <paramref name="b"/>.</returns>
    public static long Lcm(long a, long b)
    {
        if (a == 0 || b == 0) return 0;
        return Math.Abs(a / Gcd(a, b) * b);
    }

    /// <summary>
    /// Factorial (n!). Uses checked arithmetic and throws if result overflows <see cref="long"/>.
    /// </summary>
    /// <param name="n">The input value (must be non-negative).</param>
    /// <returns>The factorial of <paramref name="n"/>.</returns>
    /// <exception cref="ArgumentOutOfRangeException">Thrown when <paramref name="n"/> is negative.</exception>
    /// <exception cref="OverflowException">Thrown when the result does not fit in <see cref="long"/>.</exception>
    public static long Factorial(int n)
    {
        if (n < 0) throw new ArgumentOutOfRangeException(nameof(n), "n must be >= 0.");
        long result = 1;
        checked
        {
            for (var i = 2; i <= n; i++)
                result *= i;
        }
        return result;
    }

    /// <summary>
    /// Factorial (n!). Returns <see langword="false"/> instead of throwing on invalid input or overflow.
    /// </summary>
    /// <param name="n">The input value (must be non-negative).</param>
    /// <param name="result">The factorial of <paramref name="n"/> when successful; otherwise 0.</param>
    /// <returns><see langword="true"/> if successful; otherwise <see langword="false"/>.</returns>
    public static bool TryFactorial(int n, out long result)
    {
        if (n < 0)
        {
            result = 0;
            return false;
        }

        try
        {
            long r = 1;
            checked
            {
                for (var i = 2; i <= n; i++)
                    r *= i;
            }
            result = r;
            return true;
        }
        catch (OverflowException)
        {
            result = 0;
            return false;
        }
    }

    /// <summary>
    /// Fast primality test for 32-bit ints.
    /// </summary>
    /// <param name="n">The value to test.</param>
    /// <returns><see langword="true"/> if prime; otherwise <see langword="false"/>.</returns>
    public static bool IsPrime(int n)
    {
        if (n <= 1) return false;
        if (n <= 3) return true;
        if ((n % 2) == 0 || (n % 3) == 0) return false;

        // 6k ± 1 optimization
        for (var i = 5; (long)i * i <= n; i += 6)
        {
            if ((n % i) == 0 || (n % (i + 2)) == 0) return false;
        }

        return true;
    }

    /// <summary>
    /// Converts degrees to radians.
    /// </summary>
    /// <param name="degrees">Angle in degrees.</param>
    /// <returns>Angle in radians.</returns>
    public static double DegreesToRadians(double degrees) => degrees * (Math.PI / 180.0);

    /// <summary>
    /// Converts radians to degrees.
    /// </summary>
    /// <param name="radians">Angle in radians.</param>
    /// <returns>Angle in degrees.</returns>
    public static double RadiansToDegrees(double radians) => radians * (180.0 / Math.PI);

    /// <summary>
    /// Modulo that always returns a value in [0, modulus). Useful for wrapping indices.
    /// </summary>
    /// <param name="value">The value to reduce.</param>
    /// <param name="modulus">The modulus (must be greater than 0).</param>
    /// <returns>A value in the range [0, modulus).</returns>
    /// <exception cref="ArgumentOutOfRangeException">Thrown when <paramref name="modulus"/> is less than or equal to 0.</exception>
    public static int PositiveMod(int value, int modulus)
    {
        if (modulus <= 0) throw new ArgumentOutOfRangeException(nameof(modulus), "modulus must be > 0.");
        var r = value % modulus;
        return r < 0 ? r + modulus : r;
    }

    /// <summary>
    /// Divides two integers and returns <see langword="false"/> instead of throwing on divide-by-zero or overflow.
    /// </summary>
    /// <param name="numerator">The dividend.</param>
    /// <param name="denominator">The divisor.</param>
    /// <param name="result">The quotient if successful; otherwise 0.</param>
    /// <returns><see langword="true"/> if successful; otherwise <see langword="false"/>.</returns>
    public static bool TryDivide(int numerator, int denominator, out int result)
    {
        if (denominator == 0)
        {
            result = 0;
            return false;
        }

        // Only overflow case for signed division.
        if (numerator == int.MinValue && denominator == -1)
        {
            result = 0;
            return false;
        }

        result = numerator / denominator;
        return true;
    }

    /// <summary>
    /// Divides two integers and returns <see langword="false"/> instead of throwing on divide-by-zero or overflow.
    /// </summary>
    /// <param name="numerator">The dividend.</param>
    /// <param name="denominator">The divisor.</param>
    /// <param name="result">The quotient if successful; otherwise 0.</param>
    /// <returns><see langword="true"/> if successful; otherwise <see langword="false"/>.</returns>
    public static bool TryDivide(long numerator, long denominator, out long result)
    {
        if (denominator == 0)
        {
            result = 0;
            return false;
        }

        // Only overflow case for signed division.
        if (numerator == long.MinValue && denominator == -1)
        {
            result = 0;
            return false;
        }

        result = numerator / denominator;
        return true;
    }

    /// <summary>
    /// Divides two doubles and returns <see langword="false"/> for NaN inputs, zero denominators, or NaN results.
    /// </summary>
    /// <param name="numerator">The dividend.</param>
    /// <param name="denominator">The divisor.</param>
    /// <param name="result">The quotient if successful; otherwise 0.</param>
    /// <returns><see langword="true"/> if successful; otherwise <see langword="false"/>.</returns>
    public static bool TryDivide(double numerator, double denominator, out double result)
    {
        if (double.IsNaN(numerator) || double.IsNaN(denominator) || denominator == 0.0)
        {
            result = 0;
            return false;
        }

        result = numerator / denominator;
        return !double.IsNaN(result);
    }

    /// <summary>
    /// Computes a square root and returns <see langword="false"/> for negative inputs or NaN.
    /// </summary>
    /// <param name="value">The value to compute the square root for.</param>
    /// <param name="result">The square root if successful; otherwise 0.</param>
    /// <returns><see langword="true"/> if successful; otherwise <see langword="false"/>.</returns>
    public static bool TrySqrt(double value, out double result)
    {
        if (double.IsNaN(value) || value < 0)
        {
            result = 0;
            return false;
        }

        result = Math.Sqrt(value);
        return true;
    }

    /// <summary>
    /// Compares doubles with an absolute tolerance.
    /// </summary>
    /// <param name="a">First value.</param>
    /// <param name="b">Second value.</param>
    /// <param name="epsilon">Absolute tolerance (must be non-negative).</param>
    /// <returns><see langword="true"/> if within tolerance; otherwise <see langword="false"/>.</returns>
    /// <exception cref="ArgumentOutOfRangeException">Thrown when <paramref name="epsilon"/> is negative.</exception>
    public static bool ApproximatelyEquals(double a, double b, double epsilon = 1e-9)
    {
        if (epsilon < 0) throw new ArgumentOutOfRangeException(nameof(epsilon), "epsilon must be >= 0.");
        return Math.Abs(a - b) <= epsilon;
    }

    /// <summary>
    /// Average of values. Throws if no values are provided.
    /// </summary>
    /// <param name="values">The values to average.</param>
    /// <returns>The arithmetic mean of <paramref name="values"/>.</returns>
    /// <exception cref="ArgumentNullException">Thrown when <paramref name="values"/> is <see langword="null"/>.</exception>
    /// <exception cref="ArgumentException">Thrown when <paramref name="values"/> is empty.</exception>
    public static double Average(params double[] values)
    {
        if (values is null) throw new ArgumentNullException(nameof(values));
        if (values.Length == 0) throw new ArgumentException("At least one value is required.", nameof(values));

        double sum = 0;
        for (var i = 0; i < values.Length; i++)
            sum += values[i];

        return sum / values.Length;
    }
}
