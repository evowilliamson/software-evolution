module Duplication

import IO;
import Utils;
import Threshold;
import String;

/**
	This methods collects the metric and the associated rank
	@location 
   		the Eclipse project location
	@type 
   		the type of the file
**/

int WINDOW_SIZE = 6;
map[loc location, str code] sourcesMap = ();

/**
	This method calculates the 
**/
//public tuple[str, num, str] getMetric(loc location, str fileType, num totalLOC) {
public void getMetric(loc location, str fileType, num totalLOC) {
	ThresholdRanks thresholdRanks = [
		<66, "++">,
		<246, "+">,
		<665, "o">,
		<1310, "-">,
		<Utils::MAXINT, "--">
	];
	
	
	// Get all sources and store it together with the location in a list
	sourcesMap = getSourceFiles(location, fileType);
	for (source <- sourcesMap) {
		println(findAll(sourcesMap[source], "\n"));
		println(sourcesMap[source]);
	};
		
}

/**
   This method retrieves the code of all source files given an Eclipse project and stores it together with the 
   location in a list. It filters the source code and it also removes the import statements
   @location 
   		the Eclipse project location
   @type 
   		the type of the file
**/
public map[loc location, str code] getSourceFiles(loc location, str fileType) {
	return (a: Utils::removeEmptyLines(removeImports(Utils::filterCode(readFile(a)))) | a <- Utils::getSourceFilesInLocation(location, fileType));
}

public list[tuple[loc location, str code]] getSourceFiles2(loc location, str fileType) {
	return [<a, removeImports(Utils::filterCode(readFile(a)))> | a <- Utils::getSourceFilesInLocation(location, fileType)];
}

private str removeImports(str input) {
	// import space! this one cannot be removed: imports(...
    return visit(input) {
       case /(?m)^[\s]*?import[\s\S]*?$/ => "" 
    };
}

private void testRemoveImports() {
	str s = "import bla \n import blabla\nfkjdfkdjf kfjf dkfd\nkfdjfkdf\nfjkdsjfkd;\n fff import fjdkfjkdf \n\n import import \njfkdjfkd";
	println(s);
	println("Converted: ");
	println(removeImports(s));
}

public void testGetMetrics() {
	getMetric(|project://Jabberpoint/|, "java", 10000);
	//getMetric(|project://smallsql/|, "java", 10000);
}

public void main() {
	testGetMetrics();
}
