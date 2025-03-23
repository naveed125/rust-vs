#!/usr/bin/env julia
print("Package management ...\n")
using Pkg
Pkg.activate(".")
# Next line needed only on first run
Pkg.add( ["Random", "BenchmarkTools"] )
using Random
using BenchmarkTools
print("Package management done\n\n")

function gen_strings(n::UInt64, l::UInt64)
    """
    gen_strings generates and returns a vector of n strings of l (length) characters
    Input: n, the number of strings to return
           l, the length of each string
    Output: a vector fo n strings of l characters
    """
    charset = union( 'a':'z', 'A':'Z', '0':'9')
    return [String(rand(charset, l)) for _ in 1:n]
end

function check_dups(strings::Vector{String})
    """
    check_dups returns a dictionary of strings, with the strings as keys and a number
               of times each string apperars in the input vector
    Input: strings, a vector of strings
    Output: a dictionary of { "string1" => times1, "string2" => times2, ... }
    """
    seen = Dict{String, UInt64}()
    dups = 0
    for s in strings
        if haskey(seen, s)
            dups += 1
        else
            seen[s] = 1
        end
    end
    return dups
end

function run_experiment(n::UInt64, length::UInt64, iterations::UInt64)
    runtimes = Float64[]
    for _ in 1:iterations
        runtime = @elapsed begin
            strings = gen_strings(n, length)
            duplicates = check_dups(strings)
            println("Duplicates found: $(duplicates)")
        end
        push!(runtimes, runtime)
    end
    return runtimes
end

function main()
    n::UInt64 = 10_000
    length::UInt64 = 8
    iterations::UInt64 = 3

    runtimes = run_experiment(n, length, iterations)
    average_runtime = mean(runtimes)

    println("Runtimes: $(runtimes)")
    println("Average runtime: $(average_runtime) seconds")
end

main()
