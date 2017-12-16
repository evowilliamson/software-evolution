module UnitTesting

/**
	@author Ivo Willemsen
	Unit testing metrics is determined in quiet a naive manner, but as described by [Heitlager et al 2007]:
	First, the total number of CC is passed as an argument. This figure will be calculated first by Complexity.
	For every Code Complexity point, a test case should exist. In general one test case should perform one path and results
	in the assertion of one condition. So ideally the total CC in a system should be equal to the total number of asserts.
	This idea is used to determine the Unit Testing metric. The code is scanned for existence of the 
	word "assert" (naieve approach) and this is compared to the total CC that is passed.
	
	In practice, accurate Unit Testing metrics can only be determined by actually running the testcases and checking
	the % of paths that are covered. Any statical approach to link a test case with the actual method will be a difficult task.    
**/

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Set;

public num getUnitTesting(loc project, str fileType, num totalCC) {
	return (getNumberOfAssertStatements(project)/totalCC)*100;
}

private int getNumberOfAssertStatements(loc project) {
	int numberOfAsserts = 0;

	set[Declaration] declarations = createAstsFromEclipseProject(project, true);
	//for (i <- declarations) println(i);
	println(size(declarations));
	visit(declarations){
    	case Declaration x:class(_, /simpleName(a), _, body) : {
    		visit(body) {
    			case /System/ : numberOfAsserts += 1;
    		}
    	}
	}
	println(numberOfAsserts);
	println("fdf");
	return numberOfAsserts;
}

public void main() {
	println(getUnitTesting(|project://Jabberpoint/|, "java", 10000));
}