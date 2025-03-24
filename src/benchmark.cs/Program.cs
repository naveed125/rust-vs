using System.Text;
using System.Diagnostics;

namespace benchmark.cs
{
  class XorShift
  {
    private ulong state0, state1;

    public XorShift()
    {
      var timestamp = (ulong)DateTimeOffset.Now.ToUnixTimeSeconds();

      state0 = timestamp ^ 0xDEADBEEF;
      state1 = (timestamp << 21) ^ 0x95419C24A637B12FL;
    }

    public ulong Next()
    {
      ulong s1 = state0;
      ulong s0 = state1;

      state0 = s0;
      s1 ^= s1 << 23;
      s1 ^= s1 >>> 18;
      s1 ^= s0;
      s1 ^= s0 >>> 5;

      state1 = s1;

      return state1 + s0;
    }
  }

  class Program
  {
    public static readonly int STRING_COUNT = 10_000;
    public static readonly int STRING_LENGTH = 8;
    public static readonly char[] CHARSET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray();
    public static readonly ulong CHARSET_LENGTH = (ulong)CHARSET.Length;
    public static readonly int RUNS = 3;

    private static string RandomString(XorShift random)
    {
      var result = new StringBuilder(STRING_LENGTH);

      for (int i = 0; i < STRING_LENGTH; i++)
      {
        result.Append(CHARSET[random.Next() % CHARSET_LENGTH]);
      }

      return result.ToString();
    }

    private static IReadOnlyDictionary<string, int> GenerateStrings(int count)
    {
      var random = new XorShift();
      var stringCounts = new Dictionary<string, int>();

      for (int i = 0; i < count; i++)
      {
        var randomString = RandomString(random);

        stringCounts[randomString] = stringCounts.GetValueOrDefault(randomString, 0) + 1;
      }

      return stringCounts;
    }

    private static double measureExecutionTime()
    {
      var stopwatch = new Stopwatch();

      stopwatch.Start();
      GenerateStrings(STRING_COUNT);
      stopwatch.Stop();

      return Math.Round(stopwatch.Elapsed.TotalMilliseconds, 2);
    }

    public static void Main()
    {
      var totalTime = 0.0;
      var times = new double[RUNS];

      for (int i = 0; i < RUNS; i++)
      {
        times[i] = measureExecutionTime();
        totalTime += times[i];

        Console.Write($"{times[i]}\t");
      }

      Console.WriteLine($"{totalTime / RUNS:n2}");
    }
  }
}
