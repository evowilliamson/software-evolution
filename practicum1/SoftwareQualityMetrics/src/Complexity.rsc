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

import Utils;
import Threshold;

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
		<25, "++", 5>,
		<30, "+", 4>,
		<40, "o", 3>,		
		<50, "-", 2>,
		<MAXINT, "--", 1>
	];
	
/**
Threshold for calculating the high CC rating of a unit
See second table on page 26 of the reader
**/
private ThresholdRanksEx thresholdCCHigh = [
		<00, "++", 5>,
		<5, "+", 4>,
		<10, "o", 3>,		
		<15, "-", 2>,
		<MAXINT, "--", 1>
	];
	
/**
Threshold for calculating the very high CC rating of a unit
See second table on page 26 of the reader
**/
private ThresholdRanksEx thresholdCCVeryHigh = [
		<00, "++", 5>,
		<00, "+", 4>,
		<00, "o", 3>,		
		<5, "-", 2>,
		<MAXINT, "--", 1>
	];
	
/**
Threshold for getting the aggregrate cc of the moderate, high and very high rankings 
**/
private ThresholdRanksEx thresholdCCTotal = [
		<1, "++", 1>,
		<2, "+", 2>,
		<3, "o", 3>,		
		<4, "-", 4>,
		<5, "--", 5>
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
	
private ThresholdRanksEx thresholdUnitSize = [
		<1, "++", 1>,
		<2, "+", 2>,
		<3, "o", 3>,		
		<4, "-", 4>,
		<5, "--", 5>
	];
		
/**
Calsulates the cyclomatic complexity (cc) an the unit size (us) for every method and 
aggegrates the cc and uc into one value for cc and one value for us.  
**/
public tuple[str, str] getCyclomaticComplexityAndUnitSize(loc project, str fileType) {
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

	M3 m3 = createM3FromEclipseProject(project);
	
	//Select all methods of the M3 object
	for(method <- methods(m3)){
		//Get AST of method		
		methodAst = getMethodASTEclipse(method, model = m3);		
				
		//Get LOC of method
		int locMethod = getLOCForSourceFile(method);
		locTotal += locMethod;
				
		//Determine CC of the method
		int cc = calcCCAst(methodAst);
		str ccRank = getCCRank(cc);
		
		switch(ccRank){				
			case MODERATE: locCCModerate += locMethod;
			case HIGH: locCCHigh += locMethod;
			case VERY_HIGH: locCCVeryHigh += locMethod;
			default: locCCSimple += locMethod;
		}
										
		//Determine unit size of the method
		str unitSizeRank = getUnitSizeLocRank(locMethod);
		
		switch(unitSizeRank){
			case MODERATE: locUnitSizeModerate += locMethod;
			case HIGH: locUnitSizeHigh += locMethod;
			case VERY_HIGH: locUnitSizeVeryHigh += locMethod;
			default: locUnitSizeSimple += locMethod;
		}
		
		println("Method: <method>, loc <locMethod>, cc: <cc>, cc rank: <ccRank>, unit size: <unitSizeRank>");
						
	}
	
	//Aggregrates the calculates cc and us into one cc and us for the project 
	str ccRankStr = calculateCCRank(locTotal, locCCModerate, locCCHigh, locCCVeryHigh);
	str unitSizeRankStr = calculateUnitSizeRank(locTotal, locUnitSizeModerate, locUnitSizeHigh, locUnitSizeVeryHigh);
				
	return <ccRankStr,  unitSizeRankStr>;	
}

public str getCyclomaticMessage(str ccRankStr){
	return "Cyclomatic complexity: <ccRankStr>";
}

public str getUnitSizeMessage(str unitSizeRankStr){
	return "Unit size: <unitSizeRankStr>";
}

/**
Calculate the ccyclomatic complexity rank 
**/
private str calculateCCRank(num totalProjectLOC, real locModerate, real locHigh, real locVeryHigh){
	//Calculate the percentages of LOC per risk level
	locTotal = toReal(totalProjectLOC);
	real moderateLocPerc = (locModerate/locTotal) * 100;
	real highLocPerc = (locHigh/locTotal) * 100;
	real veryHighLocPerc = (locVeryHigh/locTotal) * 100;
	println("CC loc Total methods: <locTotal>, loc Moderate: <locModerate> (<moderateLocPerc> %), loc High: <locHigh> (<highLocPerc> %), loc Very High: <locVeryHigh> (<veryHighLocPerc> %)");	
			
	//Calculate the rank for each risk level
	int rankModerate = getRankNum(moderateLocPerc, thresholdCCModerate);
	int rankHigh = getRankNum(highLocPerc, thresholdCCHigh);
	int rankVeryHigh = getRankNum(veryHighLocPerc, thresholdCCVeryHigh);
	println("CC rank moderate: <getRank(moderateLocPerc, thresholdCCModerate)> (<rankModerate>), rank high: <getRank(highLocPerc, thresholdCCHigh)> (<rankHigh>), rank very high: <getRank(veryHighLocPerc, thresholdCCVeryHigh)> (<rankVeryHigh>)");
	
	//Calculate the aggregrated risk level
	int maxValue = max([rankModerate, rankHigh, rankVeryHigh]);	
	str rank = getRank(maxValue, thresholdCCTotal);	
	
	return rank;
}

/**
Calculate the unit size rank
**/
private str calculateUnitSizeRank(num totalProjectLOC, real locModerate, real locHigh, real locVeryHigh){
	//Calculate the percentages of LOC per risk level
	locTotal = toReal(totalProjectLOC);
	real moderateLocPerc = (locModerate/locTotal) * 100;
	real highLocPerc = (locHigh/locTotal) * 100;
	real veryHighLocPerc = (locVeryHigh/locTotal) * 100;
	println("Unit Size loc Total methods: <locTotal>, loc Moderate: <locModerate> (<moderateLocPerc> %), loc High: <locHigh> (<highLocPerc> %), loc Very High: <locVeryHigh> (<veryHighLocPerc> %)");	

	//Calculate the rank for each risk level
	int rankModerate = getRankNum(moderateLocPerc, thresholdUnitSizeModerate);
	int rankHigh = getRankNum(highLocPerc, thresholdUnitSizeHigh);
	int rankVeryHigh = getRankNum(veryHighLocPerc, thresholdUnitSizeVeryHigh);
	println("Unit Size rank moderate: <getRank(moderateLocPerc, thresholdUnitSizeModerate)> (<rankModerate>), rank high: <getRank(highLocPerc, thresholdUnitSizeHigh)> (<rankHigh>), rank very high: <getRank(veryHighLocPerc, thresholdUnitSizeVeryHigh)> (<rankVeryHigh>)");
	
	//Calculate the aggregrated risk level
	int maxValue = max([rankModerate, rankHigh, rankVeryHigh]);	
	str rank = getRank(maxValue, thresholdUnitSize);	
	
	return rank;
}

/**
 Get the rank of the cc for a unit
 1-10: simple
 11-20: moderate
 21-50: high
 >50: very high
**/
private str getCCRank(int cc){		
	str rank = getRank(cc, thresholdCCUnit);
	return rank;
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
Calculate the cc of a method. Herefore the ast is visited.
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
        case foreach(_,_,_) : result += 1;
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
	//loc project = |project://smallsql/|;
	//loc project = |project://hsqldb/|;	
	//loc project = |project://TestApplication/|;
	loc project = |project://Jabberpoint-le3/|;
	str fileType = "java";		
	
	result = getCyclomaticComplexityAndUnitSize(project, fileType);
	println("<getCyclomaticMessage(result[0])>");
	println("<getUnitSizeMessage(result[1])>");	
}