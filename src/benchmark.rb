require 'time'

# Xorshift+ state variables (64-bit)
def initialize_xorshift
  timestamp = (Time.now.to_f * 1000).to_i
  state0 = timestamp ^ 0xDEADBEEF # Arbitrary constant
  state1 = (timestamp << 21) ^ 0x95419C24A637B12F # Another arbitrary constant
  return state0 & 0xFFFFFFFFFFFFFFFF, state1 & 0xFFFFFFFFFFFFFFFF
end

# Xorshift+ function for generating pseudo-random 64-bit numbers
def xorshift_plus(state)
  s1, s0 = state
  state[0] = s0
  s1 ^= (s1 << 23) & 0xFFFFFFFFFFFFFFFF
  state[1] = (s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5)) & 0xFFFFFFFFFFFFFFFF
  return (state[1] + s0) & 0xFFFFFFFFFFFFFFFF
end

# Function to generate an 8-character random string
def generate_random_string(state)
  characters = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a
  (0...8).map { characters[xorshift_plus(state) % 62] }.join
end

# Function to generate `count` random strings and store their counts
def generate_random_strings(count)
  state = initialize_xorshift
  string_counts = Hash.new(0)

  count.times do
    random_string = generate_random_string(state)
    string_counts[random_string] += 1
  end

  string_counts
end

# Function to measure execution time
def measure_execution_time
  start_time = Time.now
  generate_random_strings(10_000)
  end_time = Time.now
  (end_time - start_time) * 1000 # Convert to milliseconds
end

# Run 3 times and measure execution time
total_time = 0
3.times do
  exec_time = measure_execution_time
  total_time += exec_time
  print format("%.2f\t", exec_time)
end

# Print average execution time
average_time = total_time / 3
puts format("%.2f", average_time)
