module Duplication

import IO;
import Utils;
import Threshold;
import String;
import List;
import Map;
import Volume;

int WINDOW_SIZE = 6;
map[loc location, str code] sourcesMap = ();
int duplicationLines = 0;

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
	
	println(size(sourcesMap));
	for (source <- sourcesMap) {
		println(source);
		processSource(source, sourcesMap[source]); 
	};

	println("totalLoc: ");
	println(totalLOC);
	println("final duplication: ");
	println(duplicationLines);
	println((duplicationLines / totalLOC) * 100);
	
		
}

private void processSource(loc location, str code) {

	list[int] eoLines = findAll(code, "\n");
	int index = 0;
	int positionFirstChar = 0;
	set[str] foundSet = {};
	while (index + WINDOW_SIZE <= size(eoLines)) {
	
		list[int] slice = eoLines[index..index + WINDOW_SIZE];
		
		str codeStringToCheck = substring(code, positionFirstChar, slice[WINDOW_SIZE - 1] + 1);
		
		if (foundDuplicationsInCurrentSource(codeStringToCheck, code)) {
			raiseDuplications();
			index = index + WINDOW_SIZE;
			positionFirstChar = slice[WINDOW_SIZE - 1] + 1;
			list[int] slice = eoLines[index..index + WINDOW_SIZE];
		}
		else {
			if (checkDuplicationsInOtherSources(codeStringToCheck, location)) {
				raiseDuplications();
				index = index + WINDOW_SIZE;
				positionFirstChar = slice[WINDOW_SIZE - 1] + 1;
				list[int] slice = eoLines[index..index + WINDOW_SIZE];
			}
			else {
				index = index + 1;
				positionFirstChar = slice[0] + 1;
			}
		};

	};
	
	println("duplication: ");
	println(duplicationLines);
	println(foundSet);
	
}

private bool foundDuplicationsInCurrentSource(str codeStringToCheck, str code) {
	return size(findAll(code, codeStringToCheck)) >= 2;
}

private bool foundBefore(str code, set[str] foundSet) {
	return code in foundSet;
}

private void raiseDuplications() {
	duplicationLines = duplicationLines + WINDOW_SIZE;
}

/**
	This method checks for duplication in sources other than the current source
**/	
private bool checkDuplicationsInOtherSources(str codeStringToCheck, loc self) {

	bool found = false;
	// Check in other sources for duplications
	for (source <- sourcesMap) {
		if (source != self && checkDuplicationInCurrentSource(codeStringToCheck, sourcesMap[source])) {
			found = true;
		};
	};	

	return found;
	
}

private bool checkDuplicationInCurrentSource(str codeStringToCheck, str code) {

	if (findFirst(code, codeStringToCheck) != -1) {
		return true;	
	};
	
	return false;
	
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
	return (a: Utils::filterCode(readFile(a)) | a <- Utils::getSourceFilesInLocation(location, fileType));
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
	//getMetric(|project://Jabberpoint/|, "java", 10000);
	//getMetric(|project://smallsql/|, "java", 10000);
	num totalLOC = Volume::getTotalLOC(|project://smallsql/|, "java");
	getMetric(|project://smallsql/|, "java", totalLOC);
}

public void main() {
	testGetMetrics();
}
