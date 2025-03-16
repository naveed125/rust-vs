import java.util.HashMap;
import java.util.Map;
import java.time.Instant;

class Xorshift {
    private long state0, state1;

    // Constructor initializes state using the current timestamp
    public Xorshift() {
        long timestamp = Instant.now().toEpochMilli();
        this.state0 = timestamp ^ 0xDEADBEEF;
        this.state1 = (timestamp << 21) ^ 0x95419C24A637B12FL;
    }

    // Xorshift+ algorithm for generating 64-bit random numbers
    public long next() {
        long s1 = state0;
        long s0 = state1;
        state0 = s0;

        s1 ^= (s1 << 23);
        s1 ^= (s1 >>> 18);
        s1 ^= s0;
        s1 ^= (s0 >>> 5);

        state1 = s1;
        return state1 + s0;
    }
}

public class Benchmark {
    private static final int STRING_COUNT = 10_000;
    private static final int STRING_LENGTH = 8;
    private static final char[] CHARSET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();

    // Function to generate an 8-character random string
    private static String generateRandomString(Xorshift rng) {
        StringBuilder sb = new StringBuilder(STRING_LENGTH);
        for (int i = 0; i < STRING_LENGTH; i++) {
            int randIndex = Math.abs((int) (rng.next() % CHARSET.length));  // Fix: Ensure positive index
            sb.append(CHARSET[randIndex]);
        }
        return sb.toString();
    }

    // Function to generate `count` random strings and track their occurrences
    private static Map<String, Integer> generateRandomStrings(int count) {
        Xorshift rng = new Xorshift();
        Map<String, Integer> stringCounts = new HashMap<>();

        for (int i = 0; i < count; i++) {
            String randomString = generateRandomString(rng);
            stringCounts.put(randomString, stringCounts.getOrDefault(randomString, 0) + 1);
        }

        return stringCounts;
    }

    // Function to measure execution time
    private static long measureExecutionTime() {
        long start = System.nanoTime();
        generateRandomStrings(STRING_COUNT);
        long end = System.nanoTime();
        return (end - start) / 1_000_000; // Convert to milliseconds
    }

    public static void main(String[] args) {
        long totalTime = 0;
        long[] times = new long[3];

        for (int i = 0; i < 3; i++) {
            long execTime = measureExecutionTime();
            totalTime += execTime;
            System.out.print(execTime + "\t");
            times[i] = execTime;
        }

        double averageTime = totalTime / 3.0;
        System.out.printf("%.2f\n", averageTime);
    }
}
