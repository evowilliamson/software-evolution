module Utils

/**
	@author Ivo Willemsen
	This module contains utility methods 
**/

import ListRelation;
import List;
import Map;
import Relation;
import Set;
import IO;
import util::Resources;
import lang::java::jdt::m3::Core;
import analysis::m3::Core;
import String;
import util::Math;

int MAXINT = 9999999;

/**
	Determines the number of newline characters in the string
	@theString: The string that needs to be searched for newline characters
	returns: the number of lines in the string
**/
private int getNumberOfLinesInString(str theString) {
	return size(findAll(theString, "\n"));
} 

/**
This method retrieves the number of lines of the given file
   @location 
   		the file location
**/
public int getLOCForSourceFile(loc file){
	s = readFile(file);
	return getNumberOfLinesInString(removeEmptyLines(filterCode(s, false)));
}

/**
This method retrieves the number of lines of the given file
	@location 
   		the file location
	@removeImports
		indicator that signifies whether imports should be ignored (true) or not (false)
	returns: the number of LOC for the file
**/
public int getLOCForSourceFile(loc file, bool removeImports){
	return getNumberOfLinesInString(removeEmptyLines(filterCode(readFile(file), removeImports)));
}

/**
   This method retrieves the number of lines per file given an Eclipse project and stores it together with the 
   location in a list
   @location 
   		the Eclipse project location
   @type 
   		the type of the file
   @removeImports
   		indicates whether the LOC should include import statements or not 
**/
public list[tuple[loc location, int lOCs]] getLOCPerSourceFile(loc location, str fileType, bool removeImports) {
	return [<a, getNumberOfLinesInString(removeEmptyLines(filterCode(readFile(a), removeImports)))> | 
					a <- getSourceFilesInLocation(location, fileType)];
}

/**
   This method retrieves all source files for a given location. 
   @location 
   		the Eclipse project location
   @type 
   		the type of the file
   return: a set of source files
**/
private set[loc] getSourceFilesInLocation(loc location, str fileType) {
	Resource project = getProject(location);
	return { a | /file(a) <- project, a.extension == fileType };
}

/**
	Get histogram X value
**/
public int getHistogramX(int x, int bucketSize) {
	real r = x / toReal(bucketSize);
	return floor(r+1) * bucketSize;
}

/**
	This method removes empty lines from the source code
	@str the input string
	returns: the source code that does not contain empty lines
**/
private str removeEmptyLines(str input) {
    return visit(input) {
       case /(\r\n)+|(\n)+/ => "\n"    // Block comments and line comments
    };
}

/**
	This method filters out comments (line and block), white space and imports.
	White space is removed for two reasons: When comparing code, leading and trailing spaces should be 
	ignored. Clearing all white space in the code takes care of that. More, clearing all white space also
	compacts the code, which makes the processing faster. It doesn't impact the duplication detection process
	and neither the volume determination process. 
	@input 
		the input that should be filtered
	@removeImports
		In case duplication is run, the TLOC should be calculated without import statements in order to get
		good %
	returns: the filtered code
**/
private str filterCode(str input, bool removeImports) {
    
    if (removeImports) {
    	return 	visit(input) {
        	case /\/\*.[\s\S]*?\*\/|\/\/.*|[ \t]+|(?!import[\s]*\(.*)[\s]*?import[\s]+?.*/ => ""
        }
    }
    else {
    	return 	visit(input) {
        	case /\/\*.[\s\S]*?\*\/|\/\/.*|[ \t]+/ => ""
        };   
    };

	return s;
}

/**
	Import statements should be removed. But invocation 
	to methods that end in "import" should not be removed
**/
private str removeImportsStatements(str input) {
	return  visit(input) {
       case /(?!import[\s]*\(.*)[\s]*?import[\s]+?.*/ => ""    
    };
 }

/**
	This methods tests the removeImports method
**/
private void testRemoveImportsStatements() {
	str s = "import bla \n import blabla\nfkjdfkdjf kfjf dkfd\nkfdjfkdf\nfjkdsjfkd;\n fff import fjdkfjkdf \n\n import(bla) \njfkdjfkd";
	println(s);
	println("Converted: ");
	println(removeImports(s));
}

/**
	This method tests the filterCode method
**/
private void testFilterCode() {
	s = "line1\nline2\n fdfdf\r\n\r\nfdfdf  /* block comment \n\n continued */ \n // fdklfkldfkld \n // fkldkflkd lfdf \nfsdfsdfdfd\n /* block comment */ jjjjj fdfdj jfkjdfkjdfd\n hhhh";
	println(s);
	println("Converted:");
	println(filterCode(s, false));
}

/**
	Calls the test methods
**/
public void main() {
 	testRemoveImportsStatements();
 	//testFilterCode();
}
