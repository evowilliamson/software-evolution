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

/**
	Entrance to metrics system
**/
public void main() {

	reportMetrics(|project://hsqldb_small/|);
	//reportMetrics(|project://core/|);
	//reportMetrics(|project://Jabberpoint-le3/|);
	//reportMetrics(|project://hsqldb_small/|);	
}

/**
	This method reports uoon the metrics for a certain system (project)
**/
private void reportMetrics(loc project) {
	num totalLOC = Volume::getTotalLOC(project, "java", false);
	ComplexityAggregate complexityAggregate = Complexity::getCyclomaticComplexityAndUnitSize(project, "java");
	DuplicationAggregate duplicationMetricAggregate = Duplication::getDuplication(project, "java");
	int unitTesting = UnitTesting::getUnitTesting(project, "java", 10000);
	
	println("Metrics for system: " + project.authority);
	println(Threshold::getMetric("Volume", totalLOC/1000, Volume::volumeRanks));
	println(Threshold::getMetric("Duplication", 
		(duplicationMetricAggregate.totalMetric/duplicationMetricAggregate.totalWeight)*100, Duplication::duplicationRanks)); 
	println(Threshold::getMetric("Unit Testing", unitTesting, UnitTesting::unitTestingRanks));
	println(Threshold::getMetric("Cyclomatic complexity", complexityAggregate.cc, Complexity::thresholdTotal)); 
	println(Threshold::getMetric("Unit size", complexityAggregate.unitSize, Complexity::thresholdTotal));
	
	reportAdditionalInformation(duplicationMetricAggregate);
	
}

private void reportAdditionalInformation(DuplicationAggregate duplicationMetricAggregate) {
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
