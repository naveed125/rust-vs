#!/usr/bin/env julia
# print("Package management ...\n")
using Pkg
Pkg.activate(".")
# Next line needed only on first run
# Pkg.add( ["Random", "BenchmarkTools", "Printf"] )
using Printf
using Random
using BenchmarkTools
# print("Package management done\n\n")

function gen_strings(n::UInt64, l::UInt64)
    """
    gen_strings generates and returns a vector of n strings of l (length) characters
    Input: n, the number of strings to return
           l, the length of each string
    Output: a vector fo n strings of l characters
    """
    charset = union( 'a':'z', 'A':'Z', '0':'9')
    return [String(rand(charset, l)) for _ in 1:n]
end # gen_strings()

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
        end # if haskey()
    end # end for s
    return dups
end # check_dups()

function run_experiment(n::UInt64, length::UInt64, iterations::UInt64)
    """
    run_experiment runs a complete cycle of 'iterations' loops, generating
                   'n' strings of 'length' chars each, removes duplicates
                   and returns the time taken by each cycle
    Input: n, number of strigs to randomly generate, length in chars of each string,
           iterations, how many times to do the generation and duplicate removal
    Output: a vector of Float64 with the times taken by each loop
    """
    runtimes = Float64[]
    for _ in 1:iterations
        runtime = @elapsed begin
            strings = gen_strings(n, length)
            duplicates = check_dups(strings)
            # println("Duplicates found: $(duplicates)")
        end # @elapsed begin
        push!(runtimes, runtime)
    end # for _
    return runtimes
end # fn run_experiment()

function main()
    LOOPS::UInt64 = 3                 # number of iterations
    STRING_COUNT::UInt64 = 10_000     # number of random strings in a dict
    STRING_LENGTH::UInt64 = 8         # length of each string
    FPDIGITS::UInt8 = 2               # precision of fp numbers to show

    runtimes = run_experiment(STRING_COUNT, STRING_LENGTH, LOOPS)
    
    for rt in runtimes
      @printf "%.*f\t" FPDIGITS 1000rt # I guess we needed to multiply by 1000
    end # for rt
    @printf "%.*f\n" FPDIGITS mean(runtimes)
    
end # fn main()

main()
