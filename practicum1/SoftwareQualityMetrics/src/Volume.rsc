module Volume

/**
	@author Ivo Willemsen
	This module contains a public method to determine the volume metric 
**/

import Threshold;
import Utils;
import util::Math;
import IO;
import util::Resources;


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
	for (a <- Utils::getLOCPerSourceFile(location, fileType, removeImports)) {
		totalLines += a.lOCs;
	}
	return totalLines;
}

/**
	Calls the test methods
**/
public void main() {
	testFilterCode();
}
