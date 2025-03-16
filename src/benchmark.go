package main

import (
	"fmt"
	"time"
)

// Xorshift+ struct
type Xorshift struct {
	state0 uint64
	state1 uint64
}

// Initialize Xorshift+ using the current timestamp
func NewXorshift() *Xorshift {
	timestamp := uint64(time.Now().UnixMilli())
	return &Xorshift{
		state0: timestamp ^ 0xDEADBEEF,
		state1: (timestamp << 21) ^ 0x95419C24A637B12F,
	}
}

// Xorshift+ PRNG function
func (x *Xorshift) Next() uint64 {
	s1 := x.state0
	s0 := x.state1
	x.state0 = s0

	s1 ^= s1 << 23
	s1 ^= s1 >> 18
	s1 ^= s0
	s1 ^= s0 >> 5

	x.state1 = s1
	return x.state1 + s0
}

// Generate an 8-character random string
func generateRandomString(rng *Xorshift) string {
	const charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	result := make([]byte, 8)

	for i := range result {
		randIndex := int(rng.Next() % uint64(len(charset)))
		result[i] = charset[randIndex]
	}

	return string(result)
}

// Generate `count` random strings and track occurrences
func generateRandomStrings(count int) map[string]int {
	rng := NewXorshift()
	stringCounts := make(map[string]int)

	for i := 0; i < count; i++ {
		randomString := generateRandomString(rng)
		stringCounts[randomString]++
	}

	return stringCounts
}

// Measure execution time in milliseconds
func measureExecutionTime() float64 {
	start := time.Now()
	generateRandomStrings(10_000)
	duration := time.Since(start).Seconds() * 1000 // Convert to milliseconds
	return duration
}

// Main function to run the test 3 times
func main() {
	var totalTime float64
	times := make([]float64, 3)

	for i := 0; i < 3; i++ {
		execTime := measureExecutionTime()
		totalTime += execTime
		fmt.Printf("%.2f\t", execTime)
		times[i] = execTime
	}

	averageTime := totalTime / 3
	fmt.Printf("%.2f\n", averageTime)
}
