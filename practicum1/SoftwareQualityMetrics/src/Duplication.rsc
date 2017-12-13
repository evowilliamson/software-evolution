module Duplication

import IO;
import Utils;
import Threshold;
import String;
import List;
import Map;
import Volume;

data WindowSlider = WindowSlider(int lineIndex, int positionFirstChar, list[int] eoLines, list[int] slice);

private int WINDOW_SIZE = 6;
private map[loc location, str code] sourcesMap = ();
private int duplicationLines = 0;
private WindowSlider windowSlider = WindowSlider(0, 0, [], []);

/**
	This method calculates the 
**/
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
		detectDuplications(source, sourcesMap[source]); 
	};

	println("totalLoc: ");
	println(totalLOC);
	println("final duplication: ");
	println(duplicationLines);
	println((duplicationLines / totalLOC) * 100);
		
}

/**
	This method checks the code for duplications in other sources. It also checks whether there
	are duplications in the code itself
	@location the location of the source 
	@code the source code
	returns: void
**/	
private void detectDuplications(loc location, str code) {

	// Create a window slider by finding all newlines in the code
	windowSlider = WindowSlider(0, 0, findAll(code, "\n"), []);
	while (canTakeNextSlice(windowSlider)) {
		windowSlider = takeNextSlice(windowSlider);
		str codeStringToCheck = getCodeString(windowSlider, code);
		if (foundDuplicationsInCurrentSource(codeStringToCheck, code)) {
			raiseDuplications();
			windowSlider = slideWindowOverDuplication(windowSlider);
		}
		else {
			if (checkDuplicationsInOtherSources(codeStringToCheck, location)) {
				println("checked: " + location.file);
				raiseDuplications();
				windowSlider = slideWindowOverDuplication(windowSlider);			
			}
			else {
				windowSlider = slideWindowToNextLine(windowSlider);
			}
		};
	};
	
}

/**
	This method checks whether a next slice can be taken.
	@windowSlider the current windowSlider
	returns: true if a new slice can be taken, false if not the case 
**/
private bool canTakeNextSlice(WindowSlider windowSlider) {
	return windowSlider.lineIndex + WINDOW_SIZE <= size(windowSlider.eoLines);
}

/**
	This method takes the next slice
	@windowSlider the current windowSlider
	returns: updated windowSlider with new slice 
**/
private WindowSlider takeNextSlice(WindowSlider windowSlider) {
	return WindowSlider(
			windowSlider.lineIndex, 
			windowSlider.positionFirstChar, 
			windowSlider.eoLines, 
			windowSlider.eoLines[windowSlider.lineIndex..windowSlider.lineIndex + WINDOW_SIZE]);
}

/**
	This method slides the window to the next line
	@windowSlider the window slider
	returns: The updated window slider
**/
private WindowSlider slideWindowToNextLine(WindowSlider windowSlider) {
	return WindowSlider(
			windowSlider.lineIndex + 1, 
			windowSlider.slice[0] + 1, 
			windowSlider.eoLines, 
			windowSlider.slice);
}

/**
	This method slides the window to the next line
	@windowSlider the window slider
	returns: The updated window slider
**/
private WindowSlider slideWindowOverDuplication(WindowSlider windowSlider) {
	return WindowSlider(
			windowSlider.lineIndex + WINDOW_SIZE, 
			windowSlider.slice[WINDOW_SIZE - 1] + 1,
			windowSlider.eoLines, 
			windowSlider.eoLines[windowSlider.lineIndex..windowSlider.lineIndex + WINDOW_SIZE]);
}

/**
	This method checks whether the codeStringToCheck can be found in the code. This method\
	is used to check whether a certain string is duplicated in the source code itself, without
	taking other sources into consideration
	@codeStringToCheck the string to look for
	@code The source code in which codeStringToCheck will be checked for existence
	returns: True if a duplication can be found in the source code itself, false if not the case 
**/
private bool foundDuplicationsInCurrentSource(str codeStringToCheck, str code) {
	return size(findAll(code, codeStringToCheck)) >= 2;
}

/**
	This method gets the code string from the current slice
	@windowSlider the window slider
	@code the code of the source
	returns: the code string that is converted from the slice
**/
private str getCodeString(WindowSlider windowSlider, str code) {
	return substring(code, windowSlider.positionFirstChar, windowSlider.slice[WINDOW_SIZE - 1] + 1);
}

/**
	Raises the number of duplicated line with the WINDOW_SIZE
	returns: void 
**/
private void raiseDuplications() {
	duplicationLines += WINDOW_SIZE;
}

/**
	This method checks for duplication in sources other than the current source
	@codeStringToCheck the string to check
	@self: the source for which other sources should be checked for duplications. It should not
			be checked with itself
	returns: true if duplications can be found in other source files, false if not the case
**/	
private bool checkDuplicationsInOtherSources(str codeStringToCheck, loc self) {

	bool found = false;
	// Check in other sources for duplications
	for (source <- sourcesMap) {
		if (source != self && checkDuplicationInCurrentSource(codeStringToCheck, sourcesMap[source])) {
			println(self);
			println(source);
			println("duplication: " + source.file + ", code string: " + codeStringToCheck);
			found = true;
		};
	};	

	return found;
	
}

/**
	This method checks for existence of codeStringToCheck in code string that is passed
	@codeStringToCheck the string to check
	@code the source code that is checked
	returns: true if there is a duplication, false if not 
**/
private bool checkDuplicationInCurrentSource(str codeStringToCheck, str code) {

	return findFirst(code, codeStringToCheck) != -1;
	
}

/**
   This method retrieves the code of all source files given an Eclipse project and stores it together with the 
   location in a list. It filters the source code and it also removes the import statements
   @location 
   		the Eclipse project location
   @type 
   		the type of the file
   returns: a map of location and its code
**/
public map[loc location, str code] getSourceFiles(loc location, str fileType) {
	return (a: Utils::removeEmptyLines(filterCode(readFile(a))) | a <- Utils::getSourceFilesInLocation(location, fileType));
}


/**
	This methods tests the removeImports method
**/
private void testRemoveImports() {
	str s = "import bla \n import blabla\nfkjdfkdjf kfjf dkfd\nkfdjfkdf\nfjkdsjfkd;\n fff import fjdkfjkdf \n\n import(bla) \njfkdjfkd";
	println(s);
	println("Converted: ");
	println(removeImports(s));
}

private str filterCode(str input) {
 	return visit(input) {
       case /\/\*.[\s\S]*?\*\/|\/\/.*|[ \t]+|[\s]*?import[\s]+?.*/ => ""    // Block comments and line comments
    };
}

/**
	This method tests the getMetrics method
**/
public void testGetMetrics() {
	//getMetric(|project://Jabberpoint/|, "java", 10000);
	//getMetric(|project://TestSoftwareQualityMetrics/|, "java", 10000);
	//getMetric(|project://smallsql/|, "java", 10000);
	//getMetric(|project://hsqldb/|, "java", 10000);
	num totalLOC = Volume::getTotalLOC(|project://hsqldb/|, "java");
	getMetric(|project://hsqldb/|, "java", totalLOC);
}

/**
	Run tests
**/
public void main() {
	testGetMetrics();
	//testRemoveImports();
}
