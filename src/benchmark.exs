defmodule RandomStringGenerator do
  import Bitwise  # Import bitwise operators (use Bitwise is deprecated)

  @num_strings 10_000
  @string_length 8
  @char_list Enum.concat([?0..?9, ?a..?z, ?A..?Z])

  # Initializes the Xorshift+ state using the current timestamp
  defp initialize_xorshift do
    timestamp = :os.system_time(:millisecond)
    state0 = Bitwise.bxor(timestamp, 0xDEADBEEF)
    state1 = Bitwise.bxor(timestamp <<< 21, 0x95419C24A637B12F)
    {state0 &&& 0xFFFFFFFFFFFFFFFF, state1 &&& 0xFFFFFFFFFFFFFFFF}
  end

  # Xorshift+ PRNG
  defp xorshift_plus({state0, state1}) do
    s1 = state0 &&& 0xFFFFFFFFFFFFFFFF
    s0 = state1

    new_state0 = s0
    s1 = Bitwise.bxor(s1, (s1 <<< 23) &&& 0xFFFFFFFFFFFFFFFF)
    new_state1 =
      Bitwise.bxor(
        Bitwise.bxor(Bitwise.bxor(s1, s0), s1 >>> 18),
        s0 >>> 5
      ) &&& 0xFFFFFFFFFFFFFFFF

    {new_state0, new_state1, (new_state1 + s0) &&& 0xFFFFFFFFFFFFFFFF}
  end

  # Generate an 8-character random string using Xorshift+
  defp generate_random_string(state) do
    {new_state, chars} =
      Enum.reduce(1..@string_length, {state, []}, fn _, {state, acc} ->
        {new_state0, new_state1, rand_value} = xorshift_plus(state)
        char = Enum.at(@char_list, rem(rand_value, 62))
        {{new_state0, new_state1}, [char | acc]}
      end)

    {new_state, to_string(Enum.reverse(chars))}
  end

  # Generate multiple random strings and count occurrences
  def generate_random_strings(count) do
    initial_state = initialize_xorshift()
    Enum.reduce(1..count, {%{}, initial_state}, fn _, {map, state} ->
      {new_state, random_string} = generate_random_string(state)
      {Map.update(map, random_string, 1, &(&1 + 1)), new_state}
    end)
    |> elem(0) # Return only the map
  end

  # Measure execution time
  def measure_execution_time do
    start_time = :os.system_time(:millisecond)
    generate_random_strings(@num_strings)
    end_time = :os.system_time(:millisecond)
    end_time - start_time
  end

  # Run 3 times and print execution times
  def run do
    times = Enum.map(1..3, fn _ -> measure_execution_time() end)
    Enum.each(times, &IO.write("#{&1}\t"))
    avg_time = Enum.sum(times) / length(times)
    IO.puts("#{Float.round(avg_time, 2)}")
  end
end

RandomStringGenerator.run()
