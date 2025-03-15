import time

def generate_random_strings():
    # Dictionary to store strings and their counts
    string_counts = {}
    
    # Get current timestamp to vary between runs
    base_seed = int(time.time() * 1000)
    
    # Generate 1000 random strings
    for i in range(10000):
        # Generate a pseudorandom string of length 8
        random_string = ""
        # Create a unique seed for each iteration
        seed = base_seed + i
        
        for _ in range(8):
            # Simple linear congruential generator
            seed = (seed * 1103515245 + 12345) % 2**31
            rand_num = seed % 62
            
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
    string_counts = generate_random_strings()
    end_time = time.time()
    
    # Convert seconds to milliseconds
    execution_time_ms = (end_time - start_time) * 1000
    total_time += execution_time_ms
    print(f"Run {i+1}: {execution_time_ms:.2f} milliseconds")
    
    # Print a sample of unique strings generated and collision count
    collision_count = sum(count > 1 for count in string_counts.values())
    print(f"  - Unique strings: {len(string_counts)}")
    print(f"  - Strings with collisions: {collision_count}")

# Calculate and print the average execution time in milliseconds
average_time_ms = total_time / 3
print(f"\nAverage execution time: {average_time_ms:.2f} milliseconds")
