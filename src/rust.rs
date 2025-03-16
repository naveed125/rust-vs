use std::collections::HashMap;
use std::time::{SystemTime, UNIX_EPOCH, Instant};

// Xorshift+ state struct
struct Xorshift {
    state0: u64,
    state1: u64,
}

impl Xorshift {
    // Initializes Xorshift+ with a timestamp seed
    fn new() -> Self {
        let timestamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("Time went backwards")
            .as_millis() as u64;

        Xorshift {
            state0: timestamp ^ 0xDEADBEEF,
            state1: (timestamp << 21) ^ 0x95419C24A637B12F,
        }
    }

    // Generates a 64-bit pseudo-random number
    fn next(&mut self) -> u64 {
        let mut s1 = self.state0;
        let s0 = self.state1;

        self.state0 = s0;
        s1 ^= s1 << 23;
        s1 ^= s1 >> 18;
        s1 ^= s0;
        s1 ^= s0 >> 5;
        self.state1 = s1;

        self.state1.wrapping_add(s0)
    }
}

// Generates a random 8-character string
fn generate_random_string(rng: &mut Xorshift) -> String {
    const CHARSET: &[u8] = b"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    let mut result = String::with_capacity(8);

    for _ in 0..8 {
        let rand_index = (rng.next() % 62) as usize;
        result.push(CHARSET[rand_index] as char);
    }

    result
}

// Generates `count` random strings and tracks their occurrences
fn generate_random_strings(count: usize) -> HashMap<String, u32> {
    let mut rng = Xorshift::new();
    let mut string_counts: HashMap<String, u32> = HashMap::new();

    for _ in 0..count {
        let random_string = generate_random_string(&mut rng);
        *string_counts.entry(random_string).or_insert(0) += 1;
    }

    string_counts
}

// Measures execution time
fn measure_execution_time() -> u128 {
    let start = Instant::now();
    generate_random_strings(10_000);
    start.elapsed().as_millis()
}

fn main() {
    let mut total_time = 0;
    let mut times = Vec::new();

    for _ in 0..3 {
        let exec_time = measure_execution_time();
        total_time += exec_time;
        print!("{}\t", exec_time);
        times.push(exec_time);
    }

    let average_time = total_time as f64 / 3.0;
    println!("{:.2}", average_time);
}
