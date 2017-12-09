module Metrics

/**
	@author Ivo Willemsen
	This module is the main module of the metric system 
**/

import Volume;
import IO;

/**
	Entrance to metrics system
**/
public void main() {

	num totalLOC = Volume::getTotalLOC(|project://smallsql/|, "java");
	println(Volume::getMetric(totalLOC));
	
	
	
	
}