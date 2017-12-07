module Volume

/**
	@author Ivo Willemsen
	This module contains a public method to determine the volume metric 
**/

import Threshold;
import Utils;
import util::Math;

str METRIC_NAME = "Volume";

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
private num getTotalLOC(loc location, str fileType) {
	int totalLines = 0;
	for (a <- getLOCPerSourceFile(location, fileType))
		totalLines += a.lOCs;
		
	return totalLines;
}

/**
	This methods prints the total LOC of the system and the associated rank
	@location 
   		the Eclipse project location
	@type 
   		the type of the file
**/
public tuple[str, num, str] getMetric(loc location, str fileType) {
	ThresholdRanks thresholdRanks = [
		<66, "++">,
		<246, "+">,
		<665, "o">,
		<1310, "-">,
		<Utils::MAXINT, "--">
	];
	num totalKLOC = getTotalLOC(location, fileType)/1000;
	return <METRIC_NAME, totalKLOC, Threshold::getRank(totalKLOC, thresholdRanks)>;		
}
