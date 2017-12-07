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

int MAXINT = 9999999;

/**
   This method retrieves the number of lines per file given an Eclipse project
   @location 
   		the Eclipse project location
   @type 
   		the type of the file
**/
public list[tuple[loc location, int lOCs]] getLOCPerSourceFile(loc location, str fileType) {
	return [<a, size(readFileLines(a))> | a <- getSourceFilesInLocation(location, fileType)];
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

