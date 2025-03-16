import time

def generate_random_strings(count=10000):
    # Dictionary to store strings and their counts
    string_counts = {}
    
    # Get current timestamp to vary between runs
    base_seed = int(time.time() * 1000)
    
    # Generate 10000 random strings
    for i in range(count):
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
