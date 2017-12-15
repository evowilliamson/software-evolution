module Metrics

/**
	@author Ivo Willemsen
	This module is the main module of the metric system 
**/

import Volume;
import Duplication;
import IO;
import Utils;
import Threshold;

ThresholdRanks volumeRanks = [
	<66, "++">,
	<246, "+">,
	<665, "o">,
	<1310, "-">,
	<Utils::MAXINT, "--">
];

ThresholdRanks duplicationRanks = [
	<3, "++">,
	<5, "+">,
	<10, "o">,
	<20, "-">,
	<Utils::MAXINT, "--">
];

/**
	Entrance to metrics system
**/
public void main() {

	reportMetrics(|project://smallsql/|);
	//reportMetrics(|project://hsqldb_small/|);
	
}

/**
	This method reports uoon the metrics for a certain system (project)
**/
private void reportMetrics(loc project) {
	num totalLOC = Volume::getTotalLOC(project, "java", false);
	println("Metrics for system: " + project.authority);
	println(
		[] + 
			Threshold::getMetric("Volume", totalLOC/1000, volumeRanks) +
			Threshold::getMetric("Duplication", Duplication::getDuplication(project, "java"), duplicationRanks)
	);
}

