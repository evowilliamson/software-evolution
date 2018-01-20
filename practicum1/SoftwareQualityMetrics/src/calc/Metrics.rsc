module calc::Metrics

/**
	@author Ivo Willemsen
	This module is the main module of the metric system reporting system. It reports on ranks and
	it also generates histograms for Complexity, Unit size and Duplication that breaksdown the 
	metrics information into fine-grained buckets to get more insight.
**/

import util::Math;
import calc::Utils;
import calc::Volume;
import calc::Duplication;
import calc::UnitTesting;
import IO;
import calc::Threshold;
import calc::Types;
import Map;
import Set;
import calc::Complexity;
import lang::csv::IO; 
import calc::Logger;
import calc::Cache;

/**
	Main method of metrics system
**/
public void main() {

	//reportMetrics(|project://smallsql/|);
	reportMetrics(|project://TestSoftwareQualityMetrics/|);
	//reportMetrics(|project://core/|);
	//reportMetrics(|project://Jabberpoint-le3/|);
	//reportMetrics(|project://hsqldb_small/|);	
	//reportMetrics(|project://hsqldb/|);
}

/**
	This method reports uoon the metrics for a certain system (project)
	@project the project
**/
private void reportMetrics(loc project) {
    calc::Cache::ClearCache();
	calc::Logger::activateToFile();
	calc::Logger::doLog("Calculation of Software Quality Metrics for system: <project.authority>"); 

	num totalLOC = calc::Volume::getTotalLOC(project, calc::Utils::FILETYPE, false);
	int unitTesting = calc::UnitTesting::getUnitTesting(project, calc::Utils::FILETYPE, 10000);
	
	DuplicationAggregate duplicationMetricAggregate = calc::Duplication::getDuplication(project, calc::Utils::FILETYPE);
	ComplexityAggregate complexityAggregate = calc::Complexity::getCyclomaticComplexityAndUnitSize(project, calc::Utils::FILETYPE);
	
	calc::Logger::doLog("\r\nMetrics for system: " + project.authority + "\r\n" + 
		"<calc::Threshold::getMetric("Volume", totalLOC/1000, calc::Volume::volumeRanks)> \r\n" + 
		"<calc::Threshold::getMetric("Duplication", (duplicationMetricAggregate.totalMetric/duplicationMetricAggregate.totalWeight)*100, calc::Duplication::duplicationRanks)> \r\n" +   
		"<calc::Threshold::getMetric("Unit Testing", unitTesting, calc::UnitTesting::unitTestingRanks)> \r\n" + 
		"<calc::Threshold::getMetric("Cyclomatic complexity", complexityAggregate.cc, calc::Complexity::thresholdTotal)> \r\n" +  
		"<calc::Threshold::getMetric("Unit size", complexityAggregate.unitSize, calc::Complexity::thresholdTotal)> \r\n"); 

	reportAdditionalDuplicationInformation(duplicationMetricAggregate);
	reportAdditionalComplexityInformation(complexityAggregate);
	calc::Cache::SaveCache();
}

/**
	This methods reports on additional information regarding duplication. Data for historgrams
	are generated and written to CSV files.
	@duplicationMetricAggregate aggregate duplication metrics
**/
private void reportAdditionalDuplicationInformation(DuplicationAggregate duplicationMetricAggregate ) {

	/** Generate a histogram that shows on the x-axis the % of duplication and on the y-axis the number of 
		units that fall into the bracket **/
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
		percentageDuplicationToCountCSV = percentageDuplicationToCountCSV + <histogramX, total>;
	};
	writeCSV(percentageDuplicationToCountCSV, |file:///temp/percentageDuplicationToCount.csv|);

}

/**
	This methods reports on additional complexity and unit size information. It creates CSV
	files that breakdown complexity and unit size information
**/
private void reportAdditionalComplexityInformation(ComplexityAggregate complexityAggregate) {

	/** Generate a histogram that shows on the x-axis the mcCabe values, and on the y-axis the number of units
		that fall into the bracket
	**/
	int histogramSize = 5;
	map[int histogramX, int number] mcCabeToCountMap = ();
	for (a <- complexityAggregate.metrics) {
		int histogramX = getHistogramX(a.complexity, histogramSize);
		int total = {try mcCabeToCountMap[histogramX] + 1; catch: 1;};
	    mcCabeToCountMap = mcCabeToCountMap + (histogramX : total);
	};

	rel[int mccabe, int number] mcCabeToCountCSV = {};
	for (histogramX <- [0, histogramSize .. max(domain(mcCabeToCountMap))+1]) {
		int total = { try mcCabeToCountMap[histogramX]; catch: 0;};
		mcCabeToCountCSV = mcCabeToCountCSV + <histogramX, total>;
	};
	writeCSV(mcCabeToCountCSV, |file:///temp/mcCabeToCount.csv|);

	/** Generate a histogram that shows on the x-axis the unit sizes, and on the y-axis the number of units
		that fall into the bracket
	**/
	map[int histogramX, int number] sizePerUnitToCount = ();
	for (a <- complexityAggregate.metrics) {
		int histogramX = getHistogramX(a.size, histogramSize);
		int total = {try sizePerUnitToCount[histogramX] + 1; catch: 1;};
	    sizePerUnitToCount = sizePerUnitToCount + (histogramX : total);
	};

	rel[int size, int number] sizePerUnitToCountCSV = {};
	for (histogramX <- [0, histogramSize .. max(domain(sizePerUnitToCount))+1]) {
		int total = { try sizePerUnitToCount[histogramX]; catch: 0;};
		sizePerUnitToCountCSV = sizePerUnitToCountCSV + <histogramX, total>;
	};
	writeCSV(sizePerUnitToCountCSV, |file:///temp/sizePerUnitToCount.csv|);

}

/**
	Get histogram X value bucket
**/
public int getHistogramX(int x, int bucketSize) {
	real r = x / toReal(bucketSize);
	return floor(r+1) * bucketSize;
}
