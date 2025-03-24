<?php
# suppress the deprecated warning from float to int conversion
error_reporting(E_ALL & ~E_DEPRECATED);

class XorShift
{
	private int $state0;
	private int $state1;

	public function __construct()
	{
		$timestamp = microtime(true) * 1000;

		$this->state0 = $timestamp ^ 0xDEADBEEF;
		$this->state1 = ($timestamp << 21) ^ 0x95419C24A637B12F;
	}

	public function next(): int
	{
		$s1 = $this->state0;
		$s0 = $this->state1;

		$this->state0 = $s0;
		$s1 ^= ($s1 << 23);
		$s1 ^= ($s1 >> 18);
		$s1 ^= $s0;
		$s1 ^= ($s0 >> 5);

		$this->state1 = $s1;

		return $this->uint($this->state0 + $s0);
	}

	private function uint(int|float $n): int
	{
		return abs(intval($n >= 0 ? $n : ((2 ** 64) + $n)));
	}
}

const STRING_LENGTH = 8;
const STRING_COUNT = 10_000;

$CHARSET = str_split('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
$CHARSET_LENGTH = count($CHARSET);

function randomString(XorShift $xorshift): string
{
	global $CHARSET, $CHARSET_LENGTH;

	$randomString = [];
	for ($i = 0; $i < STRING_LENGTH; $i++) {
		$randomString[] = $CHARSET[$xorshift->next() % $CHARSET_LENGTH];
	}

	return join('', $randomString);
}

function generateStrings(int $count): array
{
	$xorshift = new XorShift();
	$stringCounts = [];

	for ($i = 0; $i < $count; $i++) {
		$randomString = randomString($xorshift);
		if (array_key_exists($randomString, $stringCounts)) {
			++$stringCounts[$randomString];
		} else {
			$stringCounts[$randomString] = 1;
		}
	}

	return $stringCounts;
}

function measureExecutionTime(): float
{
	$startTime = microtime(true);
	generateStrings(STRING_COUNT);
	$endTime = microtime(true);

	return ($endTime - $startTime) * 1000;
}

const RUNS = 3;

$totalTime = 0.0;
$times = [];
for ($i = 0; $i < RUNS; $i++) {
	$executionTime = measureExecutionTime();
	$totalTime += $executionTime;
	$times[] = $executionTime;

	echo number_format($executionTime, 2) . "\t";
}

$averageTime = $totalTime / RUNS;
echo number_format($averageTime, 2) . PHP_EOL;
