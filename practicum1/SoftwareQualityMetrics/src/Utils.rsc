module Utils

import List;
import Map;
import Relation;
import Set;
import IO;
import util::Resources;
import lang::java::jdt::m3::Core;
import analysis::m3::Core;

/**
	@author Ivo Willemsen
	This module contains utility methods 
**/

/**
   This method retrieves the number of lines per file given an Eclipse project
   @location 
   		the Eclipse project location
   @type 
   		the type of the file
**/
public rel[loc, int] getLOCPerSourceFile(loc location, str fileType) {
	return {<a, size(readFileLines(a))> | a <- getSourceFilesInLocation(location, fileType)};
}

/**
	Gets the total number of lines in the Eclipse project that coincide with the filetype
	@location 
   		the Eclipse project location
	@type 
   		the type of the file
**/
public int getTotalLOC(loc location, str fileType) {
	int totalLines = 0;
	for (a <- getLOCPerSourceFile(location, fileType))
		totalLines += a;
	return totalLines;
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
	Resource jabber = getProject(location);
	return { a | /file(a) <- jabber, a.extension == fileType };
}


public void main() {
	//println(getSourceFilesInLocation(|project://JabberPoint/|, "java"));
	println(getLOCPerSourceFile(|project://JabberPoint/|, "java"));
	
}
