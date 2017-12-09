module Duplication

/**
	This methods collects the metric and the associated rank
	@location 
   		the Eclipse project location
	@type 
   		the type of the file
**/

int WINDOW_SIZE = 6;


/**
	This method calculates the 
**/
public tuple[str, num, str] getMetric(loc location, str fileType, num totalLOC) {
	ThresholdRanks thresholdRanks = [
		<66, "++">,
		<246, "+">,
		<665, "o">,
		<1310, "-">,
		<Utils::MAXINT, "--">
	];
	
	
	// Get all sources and store it together with the location in a list
	list[tuple[loc location, str code]] sources = getSourceFiles(location, fileType);
	
	for (a <- sources) {
		
	};
	
	//num totalKLOC = getTotalLOC(location, fileType)/1000;
	//return <METRIC_NAME, totalKLOC, Threshold::getRank(totalKLOC, thresholdRanks)>;		
}
