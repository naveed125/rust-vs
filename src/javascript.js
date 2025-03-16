class Xorshift {
    constructor() {
        // Initialize state using the current timestamp
        let timestamp = Date.now();
        this.state0 = timestamp ^ 0xDEADBEEF;
        this.state1 = (timestamp << 21) ^ 0x95419C24A637B12F;
        this.mask = BigInt("0xFFFFFFFFFFFFFFFF"); // 64-bit mask
    }

    // Xorshift+ algorithm for generating 64-bit random numbers
    next() {
        let s1 = BigInt(this.state0) & this.mask;
        let s0 = BigInt(this.state1);
        this.state0 = Number(s0);

        s1 ^= (s1 << BigInt(23)) & this.mask;
        this.state1 = Number((s1 ^ s0 ^ (s1 >> BigInt(18)) ^ (s0 >> BigInt(5))) & this.mask);
        return (BigInt(this.state1) + s0) & this.mask;
    }
}

// Function to generate an 8-character random string
function generateRandomString(rng) {
    const charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    let result = "";
    for (let i = 0; i < 8; i++) {
        let randIndex = Number(rng.next() % BigInt(62)); // Convert to normal number
        result += charset[randIndex];
    }
    return result;
}

// Function to generate `count` random strings and count occurrences
function generateRandomStrings(count) {
    const rng = new Xorshift();
    const stringCounts = new Map();

    for (let i = 0; i < count; i++) {
        let randomString = generateRandomString(rng);
        stringCounts.set(randomString, (stringCounts.get(randomString) || 0) + 1);
    }

    return stringCounts;
}

// Function to measure execution time
function measureExecutionTime() {
    const start = performance.now();
    generateRandomStrings(10000);
    const end = performance.now();
    return (end - start).toFixed(2); // Convert to milliseconds
}

// Run 3 times and print execution times
function main() {
    let totalTime = 0;
    let times = [];

    for (let i = 0; i < 3; i++) {
        let execTime = measureExecutionTime();
        totalTime += parseFloat(execTime);
        process.stdout.write(execTime + "\t");
        times.push(execTime);
    }

    let averageTime = (totalTime / 3).toFixed(2);
    console.log(averageTime);
}

main();
