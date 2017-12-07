module Threshold

/**
	@author Ivo Willemsen
	This module manages threshold and ranks 
**/

alias ThresholdRanks = list[tuple[int threshold, str rank]];

/**
	This methods retrieves the rank that is associated with the value 
	@theValue 
		the value that is being looked up in the ThresholdRanks relation
	@thresholdRanks
		the ThresholdRanks relation that contains the mapping from values to ranks
**/
public str getRank(num threshold, ThresholdRanks thresholdRanks) {
	for (a <- thresholdRanks) {
		if (threshold < a.threshold) {
			return a.rank;
		}
	};
}