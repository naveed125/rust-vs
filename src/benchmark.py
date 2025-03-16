import time

def generate_random_strings(count=10000):
    # Dictionary to store strings and their counts
    string_counts = {}
    
    # Get current timestamp for initial seeds
    timestamp = int(time.time() * 1000)
    
    # Set up Xorshift+ state (needs two 64-bit seeds)
    state0 = timestamp ^ 0xDEADBEEF  # XOR with arbitrary constant
    state1 = (timestamp << 21) ^ 0x95419C24A637B12F  # Another arbitrary constant
    
    # Generate 10000 random strings
    for i in range(count):
        # Generate a pseudorandom string of length 8
        random_string = ""
        
        for _ in range(8):
            # Xorshift+ algorithm (much better statistical properties than LCG)
            s1 = state0 & 0xFFFFFFFFFFFFFFFF  # Ensure 64-bit unsigned
            s0 = state1
            
            # Update state
            state0 = s0
            s1 ^= s1 << 23
            s1 &= 0xFFFFFFFFFFFFFFFF  # Ensure 64-bit unsigned
            state1 = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5)
            state1 &= 0xFFFFFFFFFFFFFFFF  # Ensure 64-bit unsigned
            
            # Get random value
            rand_value = (state1 + s0) & 0xFFFFFFFFFFFFFFFF
            
            # Use just enough bits for our character range (0-61)
            rand_num = rand_value % 62
            
            # Convert to character
            if rand_num < 10:  # 0-9
                char = chr(ord('0') + rand_num)
            elif rand_num < 36:  # a-z
                char = chr(ord('a') + rand_num - 10)
            else:  # A-Z
                char = chr(ord('A') + rand_num - 36)
            
            random_string += char
        
        # Add to dictionary or increment count if it exists
        if random_string in string_counts:
            string_counts[random_string] += 1
        else:
            string_counts[random_string] = 1
    
    return string_counts


# Run the function 3 times and measure execution time
total_time = 0
for i in range(3):
    start_time = time.time()
    string_counts = generate_random_strings(10000)  # Generate 10000 strings
    end_time = time.time()
    
    # Convert seconds to milliseconds
    execution_time_ms = (end_time - start_time) * 1000
    total_time += execution_time_ms
    
    # Print in CSV format to console
    print(f"{execution_time_ms:.2f}\t",end="")

# Calculate and print the average execution time in milliseconds
average_time_ms = total_time / 3
print(f"{average_time_ms:.2f}")
