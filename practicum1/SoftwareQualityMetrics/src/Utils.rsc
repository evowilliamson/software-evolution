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

int MAXINT = 9999999;

/**
   This method retrieves the number of lines per file given an Eclipse project and stores it together with the 
   location in a list
   @location 
   		the Eclipse project location
   @type 
   		the type of the file
**/
public list[tuple[loc location, int lOCs]] getLOCPerSourceFile(loc location, str fileType) {
	return [<a, getNumberOfLinesInString(filterCode(readFile(a)))> | a <- getSourceFilesInLocation(location, fileType)];
}

/**
	Determines the number of newline characters in the string
	@theString: The string that needs to be searched for newline characters
**/
private int getNumberOfLinesInString(str theString) {
	return size(findAll(theString, "\n"));
} 

/**
   This method retrieves all source files for a given locaton. A source file is defined as
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
	This method filters out comments. It uses the visit statement
	in order to examine the input string repeatedly for patterns
	@str the input string
	return: the source code that does not contain comments
**/
private str removeCommentsWhiteSpace(str input) {
    return visit(input) {
       case /\/\*.[\s\S]*?\*\/|\/\/.*|[ \t]+/ => ""    // Block comments and line comments
    };
    
}

/**
	This method removes empty lines from the source code
	@str the input string
	return: the source code that does not contain empty lines
**/
private str removeEmptyLines(str input) {
    return visit(input) {
       case /(\r\n\r\n)+|(\n\n)+/ => "\n"    // Block comments and line comments
    };
}

/*
	This method filters out unnecessary lines, i.e. lines that are not part of the source code
	@str the input string
	return: the filtered source code 
*/
private str filterCode(str input) {
	return removeEmptyLines(removeCommentsWhiteSpace(input));
}

/**
	This method tests the filterCode method
**/
private void testFilterCode() {
	s = "line1\nline2\n fdfdf\r\n\r\nfdfdf  /* block comment \n\n continued */ \n // fdklfkldfkld \n // fkldkflkd lfdf \nfsdfsdfdfd\n /* block comment */ jjjjj fdfdj jfkjdfkjdfd\n hhhh";
	println(s);
	println("Converted:");
	println(filterCode(s));
}

/**
	Calls the test methods
**/
public void main() {
	testFilterCode();
}
