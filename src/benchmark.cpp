//
// Created by Alexander Pototskiy on 18.03.25.
//

#include <iostream>
#include <unordered_map>
#include <cstring>

#define STRING_COUNT 10000
#define STRING_LENGTH 8
#define HASH_TABLE_SIZE (2 * STRING_COUNT)  // Arbitrary size for hash table

uint64_t state0, state1;

template <size_t SizeV>
class small_fixed_string
{
    char data_[SizeV + 1];

public:
    inline small_fixed_string() noexcept
    {
        data_[SizeV] = 0;
    }

    inline char * data() noexcept { return data_; }
    inline char const* data() const noexcept { return data_; }

    friend inline bool operator==(small_fixed_string const& rls, small_fixed_string const& rhs) noexcept
    {
        return 0 == std::memcmp(rls.data_, rhs.data_, SizeV);
    }

    friend inline size_t hash_value(small_fixed_string const& s) noexcept
    {
        return std::hash<std::string_view>()(std::string_view{s.data_, SizeV});
    }
};

struct small_fixed_string_hash
{
    template <size_t SizeV>
    inline size_t operator()(small_fixed_string<SizeV> const& value) const noexcept { return hash_value(value); }
};

using string_type = small_fixed_string<STRING_LENGTH>;

std::unordered_map<string_type, uint64_t, small_fixed_string_hash> hashTable;

inline uint64_t xorshift_plus() noexcept {
    uint64_t s1 = state0;
    uint64_t s0 = state1;
    state0 = s0;
    s1 ^= s1 << 23;
    s1 ^= s1 >> 18;
    s1 ^= s0;
    s1 ^= s0 >> 5;
    state1 = s1;
    return state1 + s0;
}

static const char CHARSET[] = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

// Function to generate `count` random strings and store them in a hash table
void generate_random_strings(int count) {
    hashTable.clear();
    small_fixed_string<STRING_LENGTH> random_string;

    for (int i = 0; i < count; i++) {
        for (char * data = random_string.data(), *edata = data + STRING_LENGTH; data != edata; ++data) {
            *data = CHARSET[xorshift_plus() % 62];
        }

        if (auto it = hashTable.find(random_string); it == hashTable.end()) {
            hashTable.emplace_hint(it, random_string, 1);
        } else {
            it->second++;
        }
    }
}

double get_execution_time() {
    clock_t start, end;
    start = clock();
    generate_random_strings(STRING_COUNT);
    end = clock();
    return ((double)(end - start) / CLOCKS_PER_SEC) * 1000.0; // Convert to milliseconds
}

int main() {
    // Initialize random seed
    uint64_t timestamp = (uint64_t)time(NULL) * 1000;
    state0 = timestamp ^ 0xDEADBEEF; // Arbitrary constant
    state1 = (timestamp << 21) ^ 0x95419C24A637B12F; // Arbitrary constant

    double total_time = 0.0;
    hashTable.reserve(HASH_TABLE_SIZE);
    // Run 3 times and measure execution time
    for (int i = 0; i < 3; i++) {
        double exec_time = get_execution_time();
        total_time += exec_time;
        printf("%.2f\t", exec_time);
    }

    // Print average execution time
    printf("%.2f\n", total_time / 3);

    return 0;
}
