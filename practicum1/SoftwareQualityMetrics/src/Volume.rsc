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
public num getTotalLOC(loc location, str fileType) {
	int totalLines = 0;
	for (a <- getLOCPerSourceFile(location, fileType))
		totalLines += a.lOCs;
		
	return totalLines;
}

/**
	This methods collects the metric and the associated rank
	@totalLOC total number of lines in the code 
   		the type of the file
   	return: tuple with the combination of name of the metric, total K number of LOC and the rank
**/
public tuple[str, num, str] getMetric(num totalLOC) {
	num totalKLOC = totalLOC/1000;
	ThresholdRanks thresholdRanks = [
		<66, "++">,
		<246, "+">,
		<665, "o">,
		<1310, "-">,
		<Utils::MAXINT, "--">
	];
	return <METRIC_NAME, totalKLOC, Threshold::getRank(totalKLOC, thresholdRanks)>;		
}
