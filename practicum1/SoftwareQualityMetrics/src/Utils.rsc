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
   This method retrieves the code of all source files given an Eclipse project and stores it together with the 
   location in a list
   @location 
   		the Eclipse project location
   @type 
   		the type of the file
**/
public list[tuple[loc location, str code]] getSourceFiles(loc location, str fileType) {
	return [<a, filterCode(readFile(a))> | a <- getSourceFilesInLocation(location, fileType)];
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
	This method filters out comments and white lines from the code. It uses the visit statement
	in order to examine the input string repeatedly for patterns
	@str the input string
	return: the filtered code
**/
private str filterCode(str input) {
    return visit(input) {
       case /(?s)\/\*.*?\*\// => ""    // Block comments, use (?s) to treat the regular expression as single-line mode
       case /\/\/.*/ => ""             // One-line comments
       case /^\s*$/ => ""              // Remove "empty" lines
    };
}
