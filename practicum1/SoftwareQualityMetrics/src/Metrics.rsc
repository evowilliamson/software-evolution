module Metrics

/**
	@author Ivo Willemsen
	This module is the main module of the metric system 
**/

import util::Math;
import Volume;
import Duplication;
import UnitTesting;
import IO;
import Utils;
import Threshold;
import Types;
import Map;
import Set;
import Complexity;

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

ThresholdRanks unitTestingRanks = [
	<20, "--">,
	<60, "-">,
	<80, "o">,
	<95, "+">,
	<Utils::MAXINT, "++">
];

/**
	Entrance to metrics system
**/
public void main() {

	reportMetrics(|project://smallsql/|);
	
}

/**
	This method reports uoon the metrics for a certain system (project)
**/
private void reportMetrics(loc project) {
	num totalLOC = Volume::getTotalLOC(project, "java", false);
	ccUnitSize = Complexity::getCyclomaticComplexityAndUnitSize(project, "java");
	MetricAggregate duplicationMetricAggregate = Duplication::getDuplication(project, "java");
	int unitTesting = UnitTesting::getUnitTesting(project, "java", 10000);
	
	println("Metrics for system: " + project.authority);
	println(Threshold::getMetric("Volume", totalLOC/1000, volumeRanks));
	println(Threshold::getMetric("Duplication", (duplicationMetricAggregate.totalMetric/duplicationMetricAggregate.totalWeight)*100, duplicationRanks)); 
	println(Threshold::getMetric("Unit Testing", unitTesting, unitTestingRanks));
	println(Threshold::getMetric("Cyclomatic complexity", ccUnitSize[0], Complexity::thresholdTotal)); 
	println(Threshold::getMetric("Unit size", ccUnitSize[1], Complexity::thresholdTotal));
	
	reportAdditionalInformation(duplicationMetricAggregate);
	
}

private void reportAdditionalInformation(MetricAggregate duplicationMetricAggregate) {
	int histogramSize = 50;
	map[int histogramX, tuple[int weight, int duplicated] metric] duplicationCountMap = ();
	map[int histogramX, int number] weightCountMap = ();
	for (a <- duplicationMetricAggregate.metrics) {
		int histogramX = getHistogramX(a.weight, histogramSize);
		tuple[int weight, int duplicated] v = {try duplicationCountMap[histogramX]; catch: <a.weight, a.metric>;};
	    duplicationCountMap = duplicationCountMap + 
	    	(getHistogramX(a.weight, histogramSize) : <v.weight + a.weight, v.duplicated + a.metric>);
	    weightCountMap = weightCountMap + 
	    	(getHistogramX(a.weight, histogramSize) : {try weightCountMap[getHistogramX(a.weight, histogramSize)]+1; catch: 1;});
	};

	println("");
	println("Lines per file histogram, count and duplication");
	for (histogramX <- [0, histogramSize .. max(domain(duplicationCountMap) + domain(weightCountMap))+1]) {
		tuple[int weight, int duplicated] v1 = { try duplicationCountMap[histogramX]; catch: <0, 0>;};
		real w = toReal(v1.weight);
		real d = toReal(v1.duplicated);
		real p = { try (d/w)*100.0; catch: 0.0;};
		if ({ try weightCountMap[histogramX]; catch: 0;} == 0 || p ==0) {
			continue;
		}
		println("<histogramX>, <{ try weightCountMap[histogramX]; catch: 0;}>, <p>");
	};
}
