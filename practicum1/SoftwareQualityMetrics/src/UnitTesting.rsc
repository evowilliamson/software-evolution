module UnitTesting

import IO;
import Set;
import List;
import Map;
import Relation;
import analysis::graphs::Graph;
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Resources;
import util::Math;
import util::Benchmark;
import Utils;

private str SIMPLE = "simple"; 
private str MODERATE = "moderate";
private str HIGH = "high";
private str VERY_HIGH = "very high";

	real locTotal = 0.0;
	real locSimple = 0.0;
	real locModerate = 0.0;
	real locHigh = 0.0;
	real locVeryHigh = 0.0;

public num getUnitTesting(loc project, str fileType, num totalCC) {
	// Select all methods
	list[loc] methods = [ unit | <unitHolder,unit> <- 
		createM3FromEclipseProject(project)@containment,
			unitHolder.scheme=="java+class",		
			unit.scheme=="java+method" ||
			unit.scheme=="java+constructor" ];
	return (getNumberOfAssertStatements(project)/totalCC)*100;
}

private int getNumberOfAssertStatements(loc project) {

	int numberOfAsserts = 0;

	set[Declaration] declarations = createAstsFromEclipseProject(project, true);		
	visit(declarations){
    	case Declaration x:class(_, /simpleName(a), _, body) : {
    		visit(body) {
    			case /assert/ : numberOfAsserts += 1;
    		}
    	}
	}
	
	return numberOfAsserts;

}

public void main() {

	getUnitTesting(|project://smallsql/|, "java", 10000);
	
}