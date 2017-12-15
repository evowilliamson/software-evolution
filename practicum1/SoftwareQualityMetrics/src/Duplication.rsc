module Duplication
/**
	@author Ivo Willemsen
	Duplication detection algorithm:
	
	Duplication detection algorithm is based on the comparison of strings as described by [Heitlager et al 2007].
	For every source file, a sliding window of six lines of code is used. The contents of this window (a string) is compared with:
	1. Source code in the same file that is being processed. The contents of the sliding window is skipped and comparison is started
	after the first line of the sliding window until the end of the file. The method of comparison is done by doing a findAll. If two or
	more occurences are found, a duplication exists in the current source file (we must ignore the first occurence, as this is the
	string to be checked itself).
	2. Source code in other files. A simple findFirst is done to see if there exists a match in the other source files.
	
	In case a duplication is found, the duplicated source string is stored in a duplication cache. In the steps described above,
	before consulting the source, the cache is checked first. If found in cache, the duplication count is increased. If not found
	the source code is checked in either two ways described above.
	
	Sources are compared by simply comparing strings. 6 lines of code must be compared per check. The sliding window is determined
	by first determining the starting new line and then looking for the ending new line (6 newlines further in the source). This sliding 
	window is moved through the source line by line. In case a duplication is found, the sliding window must be advanced to the line 
	after the last line in the sliding window.
	
	Another option could have been used, i.e. creating a sliding window based on a list of strings, where the list is created based on 
	splitting the source code by using the new line as a separator. But, this would incur a performance penalty (this was tested) as 
	managing lists is more expensive performance wise than managing simple strings.
**/

import IO;
import Utils;
import Threshold;
import String;
import List;
import Map;
import Volume;
import DateTime;

data WindowSlider = WindowSlider(int lineIndex, int positionFirstChar, list[int] eoLines, list[int] slice);

private int WINDOW_SIZE = 6;
private map[loc location, str code] sourcesMap = ();
private int duplicatedLines = 0;
private WindowSlider windowSlider = WindowSlider(0, 0, [], []);

alias cache = map[str, bool];
private cache duplicationCache = ();

/**
	This method calculates the percentage of duplicated lines in the system
	@loc the location
	@fileType the type of the file that should be considered
	@totalLOC the total number of lines of code in the system
	returns: % of lines that are duplicated
**/
public num getDuplication(loc location, str fileType) {
	num totalLOC = Volume::getTotalLOC(location, fileType, true);
	
	// Get all sources and store it together with the location in a list
	sourcesMap = getSourceFiles(location, fileType);
	for (source <- sourcesMap) {
		detectDuplications(source, sourcesMap[source]); 
	};
	
	return (duplicatedLines / totalLOC) * 100;
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
		// First check for duplications in the current code
		if (checkDuplicationsInCurrentSource(codeStringToCheck, code)) {
			raiseDuplications();
			windowSlider = slideWindowOverDuplication(windowSlider);
		}
		else {
			// If a duplication is not found in the current code, check other sources for duplications
			if (checkDuplicationsInOtherSources(codeStringToCheck, location)) {
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
	This method takes the next slice of source code lines
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
	This method slides the window to the next line. This method is used if the previously compared string
	does not contain a duplication. In that case, the first line of the window slider must be dropped and the next line 
	that comes after the window slider must be added to the window slider 
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
	This method slides the window to the next block of WINDOW_SIZE lines, it skips over
	the current lines that have been detected as duplicated
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
private bool checkDuplicationsInCurrentSource(str codeStringToCheck, str code) {
	return size(findAll(code, codeStringToCheck)) >= 2;
}

/**
	This method gets the code string from the source code using the window slider
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
	duplicatedLines += WINDOW_SIZE;
}

/**
	This method checks for duplication in sources other than the current source
	@codeStringToCheck the string to check
	@self: the source for which other sources should be checked for duplications. It should not
			be checked with itself
	returns: true if duplications can be found in other source files, false if not the case
**/	
private bool checkDuplicationsInOtherSources(str codeStringToCheck, loc self) {
	if (foundInCache(codeStringToCheck)) {
		return true;
	};

	// Check in other sources for duplications
	for (source <- sourcesMap) {
		if (source != self && checkDuplicationInSource(codeStringToCheck, sourcesMap[source])) {
			duplicationCache = duplicationCache + (codeStringToCheck : true);
			return true;
		};
	};	

	return false;
}

/**
	This method checks if the code string can be found in the case
	@codeStringToCheck the string that should be checked for presence in the cache
	returns: true if found in the cache, otherwise false
**/
private bool foundInCache(str codeStringToCheck) {
	try return duplicationCache[codeStringToCheck]; catch: return false;
}

/**
	This method checks for existence of codeStringToCheck in code string that is passed
	@codeStringToCheck the string to check
	@code the source code that is checked
	returns: true if there is a duplication, false if not 
**/
private bool checkDuplicationInSource(str codeStringToCheck, str code) {
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
	return (location: Utils::removeEmptyLines(Utils::filterCode(readFile(a), true)) | 
					location <- Utils::getSourceFilesInLocation(location, fileType));
}

/**
	This method tests the getMetrics method
**/
public void testGetMetrics() {
	//getMetric(|project://Jabberpoint/|, "java", 10000);
	//getMetric(|project://TestSoftwareQualityMetrics/|, "java", 10000);
	//getMetric(|project://smallsql/|, "java", 10000);
	//getMetric(|project://hsqldb_small/|, "java", 10000);
	//getMetric(|project://hsqldb/|, "java", 10000);
}

/**
	Run tests
**/
public void main() {
	testGetMetrics();
}
