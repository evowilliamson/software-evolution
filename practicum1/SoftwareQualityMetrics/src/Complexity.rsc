module Complexity

/**
	@author Marco Huijben
	This module contains methods to determine the complexity of an unit
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

private ThresholdRanks thresholdCCUnit = [
		<11, SIMPLE, 5>,
		<21, MODERATE, 4>,
		<50, HIGH, 3>,		
		<Utils::MAXINT, VERY_HIGH, 2>
	];
	
private ThresholdRanks thresholdCCModerate = [
		<25, "++", 1>,
		<30, "+", 2>,
		<40, "o", 3>,		
		<50, "-", 4>,
		<Utils::MAXINT, "--", 5>
	];
	
private ThresholdRanks thresholdCCHigh = [
		<00, "++", 1>,
		<5, "+", 2>,
		<10, "o", 3>,		
		<15, "-", 4>,
		<Utils::MAXINT, "--", 5>
	];
	
private ThresholdRanks thresholdCCVeryHigh = [
		<00, "++", 1>,
		<00, "+", 2>,
		<00, "o", 3>,		
		<5, "-", 4>,
		<Utils::MAXINT, "--", 5>
	];
	
private ThresholdRanks thresholdCCTotal = [
		<1, "++", 1>,
		<2, "+", 2>,
		<3, "o", 3>,		
		<4, "-", 4>,
		<5, "--", 5>
	];
	
/**
Get the complexity rating of the project
Works for small projects (e.g. smallsql)
**/
public str getComplexityWithM3(loc project, str fileType, num totalProjectLOC) {
	real locTotal = 0.0;
	real locSimple = 0.0;
	real locModerate = 0.0;
	real locHigh = 0.0;
	real locVeryHigh = 0.0;
	int counter = 0;

	set[loc] files = Utils::getSourceFilesInLocation(project, fileType);
	println("Amount of files in the project: <size(files)>");
	
	M3 m = createM3FromEclipseProject(project);
	
	//Select all methods
	rel[loc, loc] methods = { <x,y> | <x,y> <- m@containment,
		x.scheme=="java+class",
		y.scheme=="java+method" ||
		y.scheme=="java+constructor" };
			
	methodsClass = { <a, methods[a]> | a <- domain(methods)};
					
	//Calculate cc for every method
	for(<a,n> <- methodsClass){
		counter += 1;
		println("file <counter>: <a>");
	
		for(method <- n){
			Declaration d = getMethodASTEclipse(method, model = m);									
									
			int cc = 0;
			Statement statement;
			for(/Statement s := d) 
			{
				statement = s;										
			}				
			
			if (statement?){
				cc = calcCC(statement);
				
				int locMethod = Utils::getLOCForSourceFile(d@src);
				locTotal += locMethod;
				str rank = getCCRank(cc);
				
				switch(rank){				
					case MODERATE: locModerate += locMethod;
					case HIGH: locHigh += locMethod;
					case VERY_HIGH: locVeryHigh += locMethod;
					default: locSimple += locMethod;
				}
				
				println("Method: <method>, loc <locMethod>, cc: <cc>, rank: <rank>");
			}
			else{
				println("Error in file: <method>");
			}			
		}	
		
		gc();			
	}
	
	str rank = calculateRank(totalProjectLOC, locModerate, locHigh, locVeryHigh); 		
				
	return "Cyclomatic complexity: <rank>";
}

/**
Get the complexity rating of the project
**/
public str getComplexity(loc project, str fileType, num totalProjectLOC) {
	real locTotal = 0.0;
	real locSimple = 0.0;
	real locModerate = 0.0;
	real locHigh = 0.0;
	real locVeryHigh = 0.0;
	int counter = 0;
	
	set[loc] files = Utils::getSourceFilesInLocation(project, fileType);
	println("Amount of files in the project: <size(files)>");
	
	for(file <- files){
		counter += 1;
		println("file <counter>: <file>");
		
		M3 m = createM3FromEclipseFile(file);				
		
		//Select all methods
		list[loc] methods = [ y | <x,y> <- m@containment,
			x.scheme=="java+class",		
			y.scheme=="java+method" ||
			y.scheme=="java+constructor" ];					
				
		//Calculate cc for every method
		for(method <- methods){
			Declaration d = getMethodASTEclipse(method, model = m);									
									
			int cc = 0;
			Statement statement;
			for(/Statement s := d) 
			{
				statement = s;										
			}				
			
			if (statement?){
				cc = calcCC(statement);
				
				int locMethod = Utils::getLOCForSourceFile(d@src);
				locTotal += locMethod;
				str rank = getCCRank(cc);
				
				switch(rank){				
					case MODERATE: locModerate += locMethod;
					case HIGH: locHigh += locMethod;
					case VERY_HIGH: locVeryHigh += locMethod;
					default: locSimple += locMethod;
				}
				
				println("Method: <method>, loc <locMethod>, cc: <cc>, rank: <rank>");
			}
			else{
				println("Error in file: <method>");
			}			
		}	
				
		gc();		
	}
	
	println("loc Total methods: <totalProjectLOC>, loc Moderate: <locModerate>, loc High: <locHigh>, loc Very High: <locVeryHigh>");	
	
	str rank = calculateRank(totalProjectLOC, locModerate, locHigh, locVeryHigh); 		
				
	return "Cyclomatic complexity: <rank>";
}

/**
Get the complexity rating of the project
**/
public str getComplexityTest(loc project, str fileType, num totalProjectLOC) {
	real locTotal = 0.0;
	real locSimple = 0.0;
	real locModerate = 0.0;
	real locHigh = 0.0;
	real locVeryHigh = 0.0;
	int counter = 0;
	
	set[loc] files = Utils::getSourceFilesInLocation(project, fileType);
	println("Amount of files in the project: <size(files)>");
	
	for(file <- files){
		counter += 1;
		println("file <counter>: <file>");
		
		Declaration ast = createAstFromFile(file, false);
		println("ast =\> <ast>");
		
		visit(ast){
			case \method() : println("method 1 gevonden");			
			case \method(__) : println("method 1 gevonden");
			case \method(__,__) : println("method 1 gevonden");
			case \method(__,__,__) : println("method 1 gevonden");
			case \method(__,__,__,__) : println("method 1 gevonden");
			case \method(__,__,__,__,__) : println("method 2 gevonden");
			case \if(_,_) : println("if gevonden");			
		}
		
			
		/*
		//Select all methods
		list[loc] methods = [ y | <x,y> <- ast@method,
			x.scheme=="java+class",		
			y.scheme=="java+method" ||
			y.scheme=="java+constructor" ];					
				
		//Calculate cc for every method
		for(method <- methods){
			Declaration d = getMethodASTEclipse(method, model = m);									
									
			int cc = 0;
			Statement statement;
			for(/Statement s := d) 
			{
				statement = s;										
			}				
			
			if (statement?){
				cc = calcCC(statement);
				
				int locMethod = Utils::getLOCForSourceFile(d@src);
				locTotal += locMethod;
				str rank = getCCRank(cc);
				
				switch(rank){				
					case MODERATE: locModerate += locMethod;
					case HIGH: locHigh += locMethod;
					case VERY_HIGH: locVeryHigh += locMethod;
					default: locSimple += locMethod;
				}
				
				println("Method: <method>, loc <locMethod>, cc: <cc>, rank: <rank>");
			}
			else{
				println("Error in file: <method>");
			}			
		}	
				
		gc();
		*/		
	}
	
	println("loc Total methods: <totalProjectLOC>, loc Moderate: <locModerate>, loc High: <locHigh>, loc Very High: <locVeryHigh>");	
	
	str rank = calculateRank(totalProjectLOC, locModerate, locHigh, locVeryHigh); 		
				
	return "Cyclomatic complexity: <rank>";
}

/**
Calculate the ccyclomatic complexity rank 
**/
private str calculateRank(num totalProjectLOC, real locModerate, real locHigh, real locVeryHigh){
	//Calculate the percentages of LOC per risk level
	locTotal = toReal(totalProjectLOC);
	real moderateLocPerc = (locModerate/locTotal) * 100;
	real highLocPerc = (locHigh/locTotal) * 100;
	real veryHighLocPerc = (locVeryHigh/locTotal) * 100;
	println("loc Total methods: <locTotal>, loc Moderate: <locModerate> (<moderateLocPerc> %), loc High: <locHigh> (<highLocPerc> %), loc Very High: <locVeryHigh> (<veryHighLocPerc> %)");	
			
	//Calculate the rank for each risk level
	int rankModerate = Threshold::getRankNum(moderateLocPerc, thresholdCCModerate);
	int rankHigh = Threshold::getRankNum(highLocPerc, thresholdCCHigh);
	int rankVeryHigh = Threshold::getRankNum(veryHighLocPerc, thresholdCCVeryHigh);
	println("rank moderate: <Threshold::getRank(moderateLocPerc, thresholdCCModerate)> (<rankModerate>), rank high: <Threshold::getRank(highLocPerc, thresholdCCHigh)> (<rankHigh>), rank very high: <Threshold::getRank(veryHighLocPerc, thresholdCCVeryHigh)> (<rankVeryHigh>)");
	
	//Calculate the aggregrated risk level
	int maxValue = max([rankModerate, rankHigh, rankVeryHigh]);
	println("min value: <maxValue>");
	str rank = Threshold::getRank(maxValue, thresholdCCTotal);	
	
	return rank;
}

/**
 Get the rank of the cc
 1-10: simple
 11-20: moderate
 21-50: high
 >50: very high
**/
private str getCCRank(int cc){		
	str rank = Threshold::getRank(cc, thresholdCCUnit);
	return rank;
}

/**
Calculate the CC
Source: https://stackoverflow.com/questions/40064886/obtaining-cyclomatic-complexity
**/
private int calcCC(Statement impl) {
    int result = 1;
    visit (impl) {
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
