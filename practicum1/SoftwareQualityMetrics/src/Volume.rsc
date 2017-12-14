module Volume

/**
	@author Ivo Willemsen
	This module contains a public method to determine the volume metric 
**/

import Threshold;
import Utils;
import util::Math;

/**

TODO: // in een string!!!


**/

/**
	This methods prints the rank of the volume of the system 
	@location 
   		the Eclipse project location
	@type 
   		the type of the file
**/

/**
	Gets the total number of lines in the Eclipse project that coincide with the filetype
	@location 
   		the Eclipse project location
	@type 
   		the type of the file
**/
public num getTotalLOC(loc location, str fileType) {
	int totalLines = 0;
	for (a <- getLOCPerSourceFile(location, fileType))
		totalLines += a.lOCs;
		
	return totalLines;
}
