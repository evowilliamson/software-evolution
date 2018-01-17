module Complexity

/**
	@author Marco Huijben
	This module contains methods to determine the complexity of an unit
	
	And the unit size
	[1] https://www.sig.eu/files/en/080_Benchmark-based_Aggregation_of_Metrics_to_Ratings.pdf
**/

import IO;
import Set;
import List;
import Map;
import Relation;
import analysis::graphs::Graph;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;
import util::Math;
import util::Benchmark;
import Types;
import Utils;
import Threshold;
import Logger;
import Cache;

str METRIC_NAME = "Complexity";

private str SIMPLE = "simple"; 
private str MODERATE = "moderate";
private str HIGH = "high";
private str VERY_HIGH = "very high";

//Define the thresholds for calculatibng the Cyclomatic Complexity and the Unit size
int MAXINT = 9999999;
real MAXREAL = 9999999.0;

/**
Threshold for de CC of a unit
See first table on page 26 of the reader
**/
private ThresholdRanksEx thresholdCCUnit = [
		<11, SIMPLE, 5>,
		<21, MODERATE, 4>,
		<50, HIGH, 3>,		
		<MAXINT, VERY_HIGH, 2>
	];
	
/**
Threshold for calculating the moderate CC rating of a unit
See second table on page 26 of the reader
**/
private ThresholdRanksEx thresholdCCModerate = [
		<25, "++", 1>,
		<30, "+", 2>,
		<40, "o", 3>,		
		<50, "-", 4>,
		<MAXINT, "--", 5>
	];
	
/**
Threshold for calculating the high CC rating of a unit
See second table on page 26 of the reader
**/
private ThresholdRanksEx thresholdCCHigh = [
		<00, "++", 1>,
		<5, "+", 2>,
		<10, "o", 3>,		
		<15, "-", 4>,
		<MAXINT, "--", 5>
	];
	
/**
Threshold for calculating the very high CC rating of a unit
See second table on page 26 of the reader
**/
private ThresholdRanksEx thresholdCCVeryHigh = [
		<00, "++", 1>,
		<00, "+", 2>,
		<00, "o", 3>,		
		<5, "-", 4>,
		<MAXINT, "--", 5>
	];
	
/**
Threshold for getting the aggregrate cc or unit size of the moderate, high and very high rankings 
**/
public ThresholdRanks thresholdTotal = [
		<2, "++">,
		<3, "+">,
		<4, "o">,		
		<5, "-">,
		<6, "--">
	];

/**
Threshold for the low risk of the unit size
See column "Low risk" of table IIIa of [1]
**/
private ThresholdRanksEx thresholdUnitSizeLow = [ 
		<MAXINT, "++", 1>,
		<MAXINT, "+", 2>,
		<MAXINT, "o", 3>,		
		<MAXINT, "-", 4>,
		<MAXINT, "--", 5>
	];

/**
Threshold for the moderate risk of the unit size
See column "Moderate risk" of table IIIa of [1]
**/
private ThresholdRanksReal thresholdUnitSizeModerate = [ 
		<19.5, "++", 1>,
		<26.0, "+", 2>,
		<34.1, "o", 3>,		
		<45.9, "-", 4>,
		<MAXREAL, "--", 5>
	];
	
/**
Threshold for the high risk unit size
See column "High risk" of table IIIa of [1]
**/
private ThresholdRanksReal thresholdUnitSizeHigh = [ 
		<10.9, "++", 1>,
		<15.5, "+", 2>,
		<22.2, "o", 3>,		
		<31.4, "-", 4>,
		<MAXREAL, "--", 5>
	];
	
/**
Threshold for the very high risk unit size
See column "Very high" risk of table IIIa of [1]
**/
private ThresholdRanksReal thresholdUnitSizeVeryHigh = [ 
		<3.9, "++", 1>,
		<6.5, "+", 2>,
		<11.0, "o", 3>,		
		<18.1, "-", 4>,
		<MAXREAL, "--", 5>
	];
		
/**
Threshold for determing the risk (low, moderate, high, very high) of a unit size) depending on the LOC of a unit.
See the header of table IIIa of [1]
**/		
private ThresholdRanksEx thresholdLocUnitSize = [ 
		<30, SIMPLE, 5>,
		<44, MODERATE, 4>,
		<74, HIGH, 3>,		
		<MAXINT, VERY_HIGH, 2>
	];		
	
/**
Calsulates the cyclomatic complexity (cc) an the unit size (us) for every method and 
aggegrates the cc and uc into one value for cc and one value for us.  
**/
public ComplexityAggregate getCyclomaticComplexityAndUnitSize(loc project, str fileType) {
	real locTotal = 0.0;
	real locCCSimple = 0.0;
	real locCCModerate = 0.0;
	real locCCHigh = 0.0;
	real locCCVeryHigh = 0.0;
	real locUnitSizeSimple = 0.0;
	real locUnitSizeModerate = 0.0;
	real locUnitSizeHigh = 0.0;
	real locUnitSizeVeryHigh = 0.0;
	int counter = 0;	
	
	int totalCC = 0;

	M3 m3 = createM3FromEclipseProject(project);
	
	Logger::doLog("Start calculating Cyclomatic Complexity and Unit size");
	Logger::doLog("Walk through all methods");
	
	list[tuple[int size, int complexity]] metrics = [];
	//Select all methods of the M3 object
	for(method <- methods(m3)){
		//Get AST of method		
		methodAst = getMethodASTEclipse(method, model = m3);		
				
		//Get LOC of method
		int locMethod = getLOCForSourceFile(method);
		Logger::doLog(locMethod);
		locTotal += locMethod;
				
		//Determine CC of the method
		int cc = calcCCAst(methodAst);
		totalCC += cc;
		str ccRank = getCCRank(cc);
		
		//Add loc of method to relative Loc category
		switch(ccRank){				
			case MODERATE: locCCModerate += locMethod;
			case HIGH: locCCHigh += locMethod;
			case VERY_HIGH: locCCVeryHigh += locMethod;
			default: locCCSimple += locMethod;
		}
										
		//Determine unit size of the method
		str unitSizeRank = getUnitSizeLocRank(locMethod);
		
		//Add loc of method to relative unti size category
		switch(unitSizeRank){
			case MODERATE: locUnitSizeModerate += locMethod;
			case HIGH: locUnitSizeHigh += locMethod;
			case VERY_HIGH: locUnitSizeVeryHigh += locMethod;
			default: locUnitSizeSimple += locMethod;
		}
		
		Logger::doLog("Method: <method>, loc <locMethod>, cc: <cc>, cc rank: <ccRank>, unit size: <unitSizeRank>");			
		metrics = metrics + <locMethod, cc>;		
	}
	
	//Aggregrates the calculates cc and us into one cc and us for the project 
	num ccRankAggregrated = calculateCCRank(locTotal, locCCSimple, locCCModerate, locCCHigh, locCCVeryHigh);
	num unitSizeRankAggregrated = calculateUnitSizeRank(locTotal, locUnitSizeSimple, locUnitSizeModerate, locUnitSizeHigh, locUnitSizeVeryHigh);
				
	return ComplexityAggregate(totalCC, ccRankAggregrated, unitSizeRankAggregrated, metrics);	
}

public str getCyclomaticMessage(num ccRank){
	rank = getRank(ccRank, thresholdTotal);	
	return "Cyclomatic complexity: <rank>";
}

public str getUnitSizeMessage(num unitSizeRank){
	str rank = getRank(unitSizeRank, thresholdTotal);	
	return "Unit size: <rank>";
}

/**
Calculate the ccyclomatic complexity rank number. 
Remark: Use the threshold thresholdCCTotal to get the cc text representation 
**/
private num calculateCCRank(num totalProjectLOC, real locSimple, real locModerate, real locHigh, real locVeryHigh){
	//Calculate the percentages of LOC per risk level
	locTotal = toReal(totalProjectLOC);
	real simpleLocPerc = (locSimple/locTotal) * 100;
	real moderateLocPerc = (locModerate/locTotal) * 100;
	real highLocPerc = (locHigh/locTotal) * 100;
	real veryHighLocPerc = (locVeryHigh/locTotal) * 100;
	Logger::doLog("CC loc Total methods: <locTotal>, loc Simple: (<simpleLocPerc> %), loc Moderate: <locModerate> (<moderateLocPerc> %), loc High: <locHigh> (<highLocPerc> %), loc Very High: <locVeryHigh> (<veryHighLocPerc> %)");	
			
	//Calculate the rank for each risk level
	int rankModerate = getRankNum(moderateLocPerc, thresholdCCModerate);
	int rankHigh = getRankNum(highLocPerc, thresholdCCHigh);
	int rankVeryHigh = getRankNum(veryHighLocPerc, thresholdCCVeryHigh);
	Logger::doLog("CC rank moderate: <getRank(moderateLocPerc, thresholdCCModerate)> (<rankModerate>), rank high: <getRank(highLocPerc, thresholdCCHigh)> (<rankHigh>), rank very high: <getRank(veryHighLocPerc, thresholdCCVeryHigh)> (<rankVeryHigh>)");
	
	//Calculate the aggregrated risk level
	int maxValue = max([rankModerate, rankHigh, rankVeryHigh]);	
	
	return maxValue;
}

/**
Calculate the unit size rank. 
Remark: Use the threshold thresholdUnitSize to get the unit size string representation
**/
private num calculateUnitSizeRank(num totalProjectLOC, real locSimple, real locModerate, real locHigh, real locVeryHigh){
	//Calculate the percentages of LOC per risk level
	locTotal = toReal(totalProjectLOC);
	real simpleLocPerc = (locSimple/locTotal) * 100;
	real moderateLocPerc = (locModerate/locTotal) * 100;
	real highLocPerc = (locHigh/locTotal) * 100;
	real veryHighLocPerc = (locVeryHigh/locTotal) * 100;
	Logger::doLog("Unit Size loc Total methods: <locTotal>, loc Simple: <locSimple> (<simpleLocPerc> %), loc Moderate: <locModerate> (<moderateLocPerc> %), loc High: <locHigh> (<highLocPerc> %), loc Very High: <locVeryHigh> (<veryHighLocPerc> %)");	

	//Calculate the rank for each risk level
	int rankModerate = getRankNum(moderateLocPerc, thresholdUnitSizeModerate);
	int rankHigh = getRankNum(highLocPerc, thresholdUnitSizeHigh);
	int rankVeryHigh = getRankNum(veryHighLocPerc, thresholdUnitSizeVeryHigh);
	Logger::doLog("Unit Size rank moderate: <getRank(moderateLocPerc, thresholdUnitSizeModerate)> (<rankModerate>), rank high: <getRank(highLocPerc, thresholdUnitSizeHigh)> (<rankHigh>), rank very high: <getRank(veryHighLocPerc, thresholdUnitSizeVeryHigh)> (<rankVeryHigh>)");
	
	//Calculate the aggregrated risk level
	int maxValue = max([rankModerate, rankHigh, rankVeryHigh]);		
	
	return maxValue;
}

/**
 Get the rank of the cc for a unit
 1-10: simple
 11-20: moderate
 21-50: high
 >50: very high
**/
private str getCCRank(int cc){		
	return getRank(cc, thresholdCCUnit);
}

/**
  Get the rank of the unit size for a unit
  0-30: low
  31-44: moderate
  45-74: high
  >= 75 very high
  
  See "Benchmark-based Aggregation of Metrics to Rating", T. L. Alves, J.P. Correia and J. Visser Table IIIa.
**/
private str getUnitSizeLocRank(int linesOfCode){
	return getRank(linesOfCode, thresholdLocUnitSize);
}

/**
Calculate the cc of a method. Herefore the ast of a method is visited.
See https://stackoverflow.com/questions/40064886/obtaining-cyclomatic-complexity 
**/
private int calcCCAst(methodAst) {
    int result = 1;
    visit (methodAst) {
        case \if(_,_) : result += 1;
        case \if(_,_,_) : result += 1;
        case \case(_) : result += 1;
        case \do(_,_) : result += 1;
        case \while(_,_) : result += 1;
        case \for(_,_,_) : result += 1;
        case \for(_,_,_,_) : result += 1;
        case foreach(_,_,_) : result += 1; //Not for Java 
        case \catch(_,_): result += 1;
        case \conditional(_,_,_): result += 1;
        case infix(_,"&&",_) : result += 1;
        case infix(_,"||",_) : result += 1;
    }
    return result;
}

/**
	Main methdod for testing the cyclomatic complexity and the unit size.
**/
public void main() {
	Logger::doLog("Complexity test");
	ComplexityAggregate complexityAggregate = getCyclomaticComplexityAndUnitSize(|project://TestSoftwareQualityMetrics/|, Utils::FILETYPE);
	if (complexityAggregate.totalCC == 23) {
		Logger::doLog("total number of CC as expected");
	}
	else {
		Logger::doLog("total number of CC NOT as expected");
	}
	if (size(complexityAggregate.metrics) == 12) {
		Logger::doLog("total number units as expected");
	}
	else {
		Logger::doLog("total number units NOT as expected");
	}	
}