#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <string.h>

#define STRING_COUNT 10000
#define STRING_LENGTH 8
#define HASH_TABLE_SIZE 20000  // Arbitrary size for hash table

// Simple structure for hash table entries
typedef struct StringNode {
    char string[STRING_LENGTH + 1]; // Store string (8 chars + null terminator)
    int count;
    struct StringNode *next; // For handling collisions (linked list)
} StringNode;

StringNode *hashTable[HASH_TABLE_SIZE]; // Hash table for storing unique strings

// Xorshift+ state variables (64-bit)
uint64_t state0, state1;

// Xorshift+ function for generating pseudo-random 64-bit numbers
uint64_t xorshift_plus() {
    uint64_t s1 = state0;
    uint64_t s0 = state1;
    state0 = s0;
    s1 ^= s1 << 23;
    s1 ^= s1 >> 18;
    s1 ^= s0;
    s1 ^= s0 >> 5;
    state1 = s1;
    return state1 + s0;
}

// Function to generate an 8-character random string
void generate_random_string(char *buffer) {
    for (int i = 0; i < STRING_LENGTH; i++) {
        uint64_t rand_value = xorshift_plus() % 62;

        if (rand_value < 10) { // 0-9
            buffer[i] = '0' + rand_value;
        } else if (rand_value < 36) { // a-z
            buffer[i] = 'a' + (rand_value - 10);
        } else { // A-Z
            buffer[i] = 'A' + (rand_value - 36);
        }
    }
    buffer[STRING_LENGTH] = '\0'; // Null-terminate the string
}

// Simple hash function for storing strings in a hash table
unsigned int hash_function(const char *str) {
    unsigned int hash = 5381;
    while (*str) {
        hash = ((hash << 5) + hash) + (*str); // djb2 hash algorithm
        str++;
    }
    return hash % HASH_TABLE_SIZE;
}

// Function to insert or increment count of a string in the hash table
void insert_or_increment(const char *str) {
    unsigned int hash_index = hash_function(str);
    StringNode *node = hashTable[hash_index];

    // Search for existing string
    while (node != NULL) {
        if (strcmp(node->string, str) == 0) {
            node->count++;
            return;
        }
        node = node->next;
    }

    // If string not found, insert new node
    node = (StringNode *)malloc(sizeof(StringNode));
    strcpy(node->string, str);
    node->count = 1;
    node->next = hashTable[hash_index]; // Insert at the head of linked list
    hashTable[hash_index] = node;
}

// Function to generate `count` random strings and store them in a hash table
void generate_random_strings(int count) {
    char random_string[STRING_LENGTH + 1];

    for (int i = 0; i < count; i++) {
        generate_random_string(random_string);
        insert_or_increment(random_string);
    }
}

// Function to free hash table memory
void free_hash_table() {
    for (int i = 0; i < HASH_TABLE_SIZE; i++) {
        StringNode *node = hashTable[i];
        while (node) {
            StringNode *temp = node;
            node = node->next;
            free(temp);
        }
    }
}

// Function to measure execution time
double get_execution_time() {
    clock_t start, end;
    start = clock();
    generate_random_strings(STRING_COUNT);
    end = clock();
    return ((double)(end - start) / CLOCKS_PER_SEC) * 1000.0; // Convert to milliseconds
}

int main() {
    // Initialize random seed
    uint64_t timestamp = (uint64_t)time(NULL) * 1000;
    state0 = timestamp ^ 0xDEADBEEF; // Arbitrary constant
    state1 = (timestamp << 21) ^ 0x95419C24A637B12F; // Arbitrary constant

    double total_time = 0.0;

    // Run 3 times and measure execution time
    for (int i = 0; i < 3; i++) {
        double exec_time = get_execution_time();
        total_time += exec_time;
        printf("%.2f\t", exec_time);
    }

    // Print average execution time
    printf("%.2f\n", total_time / 3);

    // Free allocated memory
    free_hash_table();
    
    return 0;
}
