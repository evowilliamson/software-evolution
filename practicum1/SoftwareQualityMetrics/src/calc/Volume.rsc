module calc::Volume

/**
	@author Ivo Willemsen
	This module contains a public method to determine the volume metric. 
	This metric is determined by applying the following preprocessing steps:
	1. Remove block comments
	2. Remove single line comments
	3. Removing white space
	4. Removing empty lines
**/

import calc::Threshold;
import calc::Utils;
import util::Math;
import IO;
import util::Resources;
import calc::Logger;

public ThresholdRanks volumeRanks = [
	<66, "++">,
	<246, "+">,
	<665, "o">,
	<1310, "-">,
	<Utils::MAXINT, "--">
];

/**
	Gets the total number of lines in the Eclipse project that coincide with the filetype
	@location 
   		the Eclipse project location
	@type 
   		the type of the file
   @removeImports
   		indicates whether the TLOC should include import statements or not 
**/
public int getTotalLOC(loc location, str fileType, bool removeImports) {
	int totalLines = 0;
	for (a <- calc::Utils::getLOCPerSourceFile(location, fileType, removeImports)) {
		totalLines += a.lOCs;
	}
	return totalLines;
}

/**
	Calls the test methods
**/
public void main() {
	int totalLOCDupNotRem = getTotalLOC(|project://smallsql/|, Utils::FILETYPE, false);
	int totalLOCDupRem = getTotalLOC(|project://smallsql/|, Utils::FILETYPE, true);
	calc::Logger::doLog("false");
	calc::Logger::doLog(totalLOCDupNotRem);
	calc::Logger::doLog("true");
	calc::Logger::doLog(totalLOCDupRem);
	if (totalLOC == 104) {
		calc::Logger::doLog("Total number of lines of code as expected");
	}
	else {
		calc::Logger::doLog("Total number of lines of code NOT as expected");
	}
}
