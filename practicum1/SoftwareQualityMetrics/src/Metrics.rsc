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
import lang::csv::IO; 

/**
	Entrance to metrics system
**/
public void main() {
	//reportMetrics(|project://hsqldb_small/|);
	//reportMetrics(|project://core/|);
	//reportMetrics(|project://Jabberpoint-le3/|);
	//reportMetrics(|project://hsqldb_small/|);
	//reportMetrics(|project://TestApplication/|);	
	reportMetrics(|project://smallsql/|);	
}

/**
	This method reports uoon the metrics for a certain system (project)
**/
private void reportMetrics(loc project) {
	loc logfile = |project://SoftwareQualityMetrics/reports/Metrics.txt|;
	writeFile(logfile, "Calculation Cyclomatic Complexity And Unit Size\r\n");	

	num totalLOC = Volume::getTotalLOC(project, "java", false);

	ComplexityAggregate complexityAggregate = Complexity::getCyclomaticComplexityAndUnitSize(project, "java", logfile);
	DuplicationAggregate duplicationMetricAggregate = Duplication::getDuplication(project, "java");
	int unitTesting = UnitTesting::getUnitTesting(project, "java", 10000);	

	str txt = "\r\nMetrics for system: " + project.authority + "\r\n" +
	"<Threshold::getMetric("Volume", totalLOC/1000, Volume::volumeRanks)> \r\n" +
	"<Threshold::getMetric("Duplication", (duplicationMetricAggregate.totalMetric/duplicationMetricAggregate.totalWeight)*100, Duplication::duplicationRanks)> \r\n" +  
	"<Threshold::getMetric("Unit Testing", unitTesting, UnitTesting::unitTestingRanks)> \r\n" +
	"<Threshold::getMetric("Cyclomatic complexity", complexityAggregate.cc, Complexity::thresholdTotal)> \r\n" + 
	"<Threshold::getMetric("Unit size", complexityAggregate.unitSize, Complexity::thresholdTotal)> \r\n";

	appendToFile(logfile, txt);
	println(txt);	
	
	reportAdditionalInformation(duplicationMetricAggregate, complexityAggregate, logfile);
}

private void reportAdditionalInformation(DuplicationAggregate duplicationMetricAggregate, ComplexityAggregate complexityAggregate, loc logfile) {
	int histogramSize = 50;
	str txt = "\r\nLines per file histogram, count and duplication\r\n";

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
	
	for (histogramX <- [0, histogramSize .. max(domain(duplicationCountMap) + domain(weightCountMap))+1]) {
		tuple[int weight, int duplicated] v1 = { try duplicationCountMap[histogramX]; catch: <0, 0>;};
		real w = toReal(v1.weight);
		real d = toReal(v1.duplicated);
		real p = { try (d/w)*100.0; catch: 0.0;};
		if ({ try weightCountMap[histogramX]; catch: 0;} == 0 || p == 0) {
			continue;
		}
		txt += "<histogramX>, <{ try weightCountMap[histogramX]; catch: 0;}>, <p>\r\n";
	};	

	appendToFile(logfile, txt);
	println(txt);

	println("");
	println("% duplication histogram, number of units");
	histogramSize = 5;
	map[int histogramX, int number] percentageDuplicationToCountMap = ();
	for (a <- duplicationMetricAggregate.metrics) {
		real w = toReal(a.weight);
		real d = toReal(a.metric);
		real p = { try (d/w)*100.0; catch: 0.0;};
		int histogramX = getHistogramX(round(p), histogramSize);
		int total = {try percentageDuplicationToCountMap[histogramX] + 1; catch: 1;};
	    percentageDuplicationToCountMap = percentageDuplicationToCountMap + (histogramX : total);
	};

	rel[int percentage, int number] percentageDuplicationToCountCSV = {};
	for (histogramX <- [0, histogramSize .. 101]) {
		int total = { try percentageDuplicationToCountMap[histogramX]; catch: 0;};
		println("<histogramX>, <total>");
		percentageDuplicationToCountCSV = percentageDuplicationToCountCSV + <histogramX, total>;
	};
	writeCSV(percentageDuplicationToCountCSV, |file:///tmp/percentageDuplicationToCount.csv|);

	println("");
	println("McCabe, number of units:");
	histogramSize = 10;
	map[int histogramX, int number] mcCabeToCountMap = ();
	for (a <- complexityAggregate.metrics) {
		int histogramX = getHistogramX(a.complexity, histogramSize);
		int total = {try mcCabeToCountMap[histogramX] + 1; catch: 1;};
	    mcCabeToCountMap = mcCabeToCountMap + (histogramX : total);
	};

	rel[int size, int number] mcCabeToCountCSV = {};
	for (histogramX <- [0, histogramSize .. max(domain(mcCabeToCountMap))+1]) {
		int total = { try mcCabeToCountMap[histogramX]; catch: 0;};
		println("<histogramX>, <total>");
		mcCabeToCountCSV = mcCabeToCountCSV + <histogramX, total>;
	};
	writeCSV(mcCabeToCountCSV, |file:///tmp/mcCabeToCount.csv|);

	println("");
	println("Size per unit, number of units:");
	histogramSize = 10;
	map[int histogramX, int number] sizePerUnitToCount = ();
	for (a <- complexityAggregate.metrics) {
		int histogramX = getHistogramX(a.size, histogramSize);
		int total = {try sizePerUnitToCount[histogramX] + 1; catch: 1;};
	    sizePerUnitToCount = sizePerUnitToCount + (histogramX : total);
	};

	rel[int size, int number] sizePerUnitToCountCSV = {};
	for (histogramX <- [0, histogramSize .. max(domain(sizePerUnitToCount))+1]) {
		int total = { try sizePerUnitToCount[histogramX]; catch: 0;};
		println("<histogramX>, <total>");
		sizePerUnitToCountCSV = sizePerUnitToCountCSV + <histogramX, total>;
	};
	writeCSV(sizePerUnitToCountCSV, |file:///tmp/sizePerUnitToCount.csv|);
}
