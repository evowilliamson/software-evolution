module metrics::UnitTesting

/**
	@author Ivo Willemsen
	Unit testing metrics is determined in quiet a naive manner, but as described by [Heitlager et al 2007]:
	First, the total number of CC is passed as an argument. This figure will be calculated first by Complexity.
	For every Code Complexity point, a test case should exist. In general, one test case should perform one path and results
	in the assertion of one condition. So ideally, the total CC in a system should be equal to the total number of asserts.
	This idea is used to determine the Unit Testing metric. The code is scanned for existence of the 
	word "assert" (naieve approach) and this is compared to the total CC that is passed.
	
	In practice, accurate Unit Testing metrics can only be determined by actually running the testcases and checking
	the % of paths that are covered. Any statical approach to link a test case with the actual method will be a difficult and 
	inaccorate task.    
**/

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Set;
import metrics::Threshold;
import metrics::Utils;
import metrics::Logger;

public ThresholdRanks unitTestingRanks = [
	<20, "--">,
	<60, "-">,
	<80, "o">,
	<95, "+">,
	<Utils::MAXINT, "++">
];

/**
	Returns the unit test coverage. This is defined as the number of assert statements
	divided by the totalCC * 100
	@loc the location
	returns: the % test case coverage
**/
public int getUnitTesting(loc project, str fileType, int totalCC) {
	return (getNumberOfAssertStatements(project)/totalCC)*100;
}

public int getUnitTesting2(loc project, str fileType, int totalCC) {
	return (getNumberOfAssertStatements(project)/totalCC)*100;
}

/**
	This method retrieves the number of assert statements found in the project
	@loc the location
	returns: the number of assert statements found
**/
private int getNumberOfAssertStatements(loc project) {
	int numberOfAsserts = 0;

	M3 m3 = createM3FromEclipseProject(project);
	int result = 0;
	for(method <- methods(m3)){
		methodAst = getMethodASTEclipse(method, model = m3);	
		 visit (methodAst) {
        	case \assert(_) : result += 1;
        	case \assert(_,_) : result += 1;
	    }	
	}
	return result;
}

private int getNumberOfAssertStatements2(loc project) {
	int numberOfAsserts = 0;

	sourcesMap = getSourceFiles(location, "java");
	for (source <- sourcesMap) {
	};
	return result;
}

/**
	Test the getUnitTesting method
**/
public void main() {
	int asserts = getUnitTesting(|project://TestSoftwareQualityMetrics/|, Utils::FILETYPE, 3);
	Logger::doLog(asserts);
	if (asserts == 100) {
		Logger::doLog("Number of tests as expected");
	}
	else {
		Logger::doLog("Number of tests NOT as expected");
	}
}