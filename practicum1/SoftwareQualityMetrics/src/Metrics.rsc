module Metrics

/**
	@author Ivo Willemsen
	This module is the main module of the metric system reporting system. It reports on ranks and
	it also generates histograms for Complexity, Unit size and Duplication that breaksdown the 
	metrics information into fine-grained buckets to get more insight.
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
import Logger;

/**
	Main method of metrics system
**/
public void main() {


	reportMetrics(|project://smallsql/|);
	//reportMetrics(|project://TestSoftwareQualityMetrics/|);
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

	Logger::activateToFile();
	Logger::doLog("Calculation of Software Quality Metrics for system: <project.authority>"); 

	num totalLOC = Volume::getTotalLOC(project, Utils::FILETYPE, false);
	int unitTesting = UnitTesting::getUnitTesting(project, Utils::FILETYPE, 10000);
	
	ComplexityAggregate complexityAggregate = Complexity::getCyclomaticComplexityAndUnitSize(project, Utils::FILETYPE);
	DuplicationAggregate duplicationMetricAggregate = Duplication::getDuplication(project, Utils::FILETYPE);
	
	Logger::doLog("\r\nMetrics for system: " + project.authority + "\r\n" + 
		"<Threshold::getMetric("Volume", totalLOC/1000, Volume::volumeRanks)> \r\n" + 
		"<Threshold::getMetric("Duplication", (duplicationMetricAggregate.totalMetric/duplicationMetricAggregate.totalWeight)*100, Duplication::duplicationRanks)> \r\n" +   
		"<Threshold::getMetric("Unit Testing", unitTesting, UnitTesting::unitTestingRanks)> \r\n" + 
		"<Threshold::getMetric("Cyclomatic complexity", complexityAggregate.cc, Complexity::thresholdTotal)> \r\n" +  
		"<Threshold::getMetric("Unit size", complexityAggregate.unitSize, Complexity::thresholdTotal)> \r\n"); 

	reportAdditionalDuplicationInformation(duplicationMetricAggregate);
	reportAdditionalComplexityInformation(complexityAggregate);
	
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
