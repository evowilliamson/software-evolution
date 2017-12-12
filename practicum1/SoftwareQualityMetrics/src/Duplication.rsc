module Duplication

import IO;
import Utils;

/**
	This methods collects the metric and the associated rank
	@location 
   		the Eclipse project location
	@type 
   		the type of the file
**/

int WINDOW_SIZE = 6;

/**
	This method calculates the 
**/
public tuple[str, num, str] getMetric(loc location, str fileType, num totalLOC) {
	ThresholdRanks thresholdRanks = [
		<66, "++">,
		<246, "+">,
		<665, "o">,
		<1310, "-">,
		<Utils::MAXINT, "--">
	];
	
	
	// Get all sources and store it together with the location in a list
	list[tuple[loc location, str code]] sources = getSourceFiles(location, fileType);
	
	for (a <- sources) {
		
	};
		
}

/**
   This method retrieves the code of all source files given an Eclipse project and stores it together with the 
   location in a list. It filters the source code and it also removes the import statements
   @location 
   		the Eclipse project location
   @type 
   		the type of the file
**/
public list[tuple[loc location, str code]] getSourceFiles(loc location, str fileType) {
	return [<a, Utils::removeImports(Utils::filterCode(readFile(a)))> | a <- Utils::getSourceFilesInLocation(location, fileType)];
}


private str removeImports(str input) {
    return visit(input) {
       case /(?m)^[\s]*?import[\s\S]*?$/ => "" 
    };
}

private void testRemoveImports() {
	str s = "import bla \n import blabla\nfkjdfkdjf kfjf dkfd\nkfdjfkdf\nfjkdsjfkd;\n  import fjdkfjkdf \n\n import import \njfkdjfkd";
	println(s);
	println("Converted: ");
	println(removeImports(s));
}

public void main() {
	testRemoveImports();
}
