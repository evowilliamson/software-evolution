module Opgave5

import IO;
import List;
import Map;
import Relation;
import Set;

private rel[int, int] calculateDivisors(int maxnum) {
   return { <a, b> | a <- [1..maxnum], b <- [1..a+1], a % b == 0 };
}

private set[int] calculateNumbersWithMostDivisors(rel[int, int] divisors) {
	map[int, int] m = (a:size(divisors[a]) | a <- domain(divisors));
   	int maxdiv = max(range(m)); 
   	return { a | a <- domain(divisors), m[a] == maxdiv };
} 

private list[int] calculatePrimeNumbersSortAscending(int maxnum) {
	
	rel[int, int] divisors = calculateDivisors(300);
	map[int, int] m = (a:size(divisors[a]) | a <- domain(divisors));
	return sort([ a | a <- domain(m), m[a] == 2 ]);
	
} 

public void main() {

	println("");
	println("Opgave 5a:");
	rel[int, int] divisors = calculateDivisors(300);
	println(divisors);
	println("");
	println("Opgave 5b:");
 	println(calculateNumbersWithMostDivisors(divisors));
	println("");
	println("Opgave 5c:");
 	println(calculatePrimeNumbersSortAscending(100));
 	
}

