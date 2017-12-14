module Threshold

/**
	@author Ivo Willemsen
	This module manages threshold and ranks 
**/

alias ThresholdRanks = list[tuple[int threshold, str rank]];

/**
	This methods collects the metric and the associated rank
	@totalLOC total number of lines in the code 
   		the type of the file
   	return: tuple with the combination of name of the metric, total K number of LOC and the rank
**/
public tuple[str, num, str] getMetric(str metricName, num threshold, ThresholdRanks thresholdRanks) {
	return <metricName, threshold, getRank(threshold, thresholdRanks)>;		
}

/**
	This methods retrieves the rank that is associated with the value 
	@theValue 
		the value that is being looked up in the ThresholdRanks relation
	@thresholdRanks
		the ThresholdRanks relation that contains the mapping from values to ranks
**/
private str getRank(num threshold, ThresholdRanks thresholdRanks) {
	for (a <- thresholdRanks) {
		if (threshold < a.threshold) {
			return a.rank;
		}
	};
}

