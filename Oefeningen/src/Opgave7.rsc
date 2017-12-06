module Opgave7

import IO;
import List;
import Map;
import Relation;
import Set;
import analysis::graphs::Graph;
import util::Resources;
import lang::java::jdt::m3::Core;
import analysis::m3::Core;

loc location = |project://JabberPoint/|;

public int getNumberOfJavaFilesInLocation(loc location) {
	return size(getJavaFilesInLocation(location));
}

public set[loc] getJavaFilesInLocation(loc location) {
	Resource jabber = getProject(location);
	return { a | /file(a) <- jabber, a.extension == "java" };
}

public bool descending(tuple[&a, num] x, tuple[&a, num] y) {
   return x[1] > y[1];
} 

private list[tuple[value, num]] getNumberOfLinesPerFileDescending(loc location) {
	set[loc] files = getJavaFilesInLocation(location);
	map[loc, int] lines = ( a:size(readFileLines(a)) | a <- files);
	return sort(toList(lines), descending);
}

private list[tuple[value, num]] getClassesSortedByNumberOfMethods(loc location) {
	M3 model = createM3FromEclipseProject(location);
	classes_Methods =  { <x,y> | <x,y> <- model@containment
                       , x.scheme=="java+class"
                       , y.scheme=="java+method" || y.scheme=="java+constructor"};
  	classes_NumberOfMethods = {<a, size(classes_Methods[a])> | a <- domain(classes_Methods)};
  	return sort(classes_NumberOfMethods, descending);
}

private list[tuple[value, num]] getClassesWithMostSubclasses(loc location) {
	M3 model = createM3FromEclipseProject(location);
	subClasses = invert(model@extends);
   	classes_Subclasses = { <a, size((subClasses+)[a])> | a <- domain(subClasses) };
   	return sort(classes_Subclasses, descending);
}



public void main() {
	
	println("");
	println("Opgave 7a:");
	println(getNumberOfJavaFilesInLocation(location));
	println("");
	println("Opgave 7b:");
	println(getNumberOfLinesPerFileDescending(location));
	println("");
	println("Opgave 7c:");
	println(getClassesSortedByNumberOfMethods(location));
	println("");
	println("Opgave 7d:");
	println(getClassesWithMostSubclasses(location));
	
}