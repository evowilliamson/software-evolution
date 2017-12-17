module Logger

import IO;
import util::Math;

/**
	@author Ivo Willemsen
	Log module that provides functionality to log to console or a file
**/
private loc logfile = |project://SoftwareQualityMetrics/reports/Metrics.txt|; 
private bool logToFile = false;
private bool logToConsole = true;
private bool initialized = false;

/**
	This method is called when the log system has not been initialized before
**/
private void initialize(str initString) {
	if (logToFile) {
		writeFile(logfile, initString + "\r\n");
		initialized = true;
	}
	if (logToConsole) {
		println(initString);
		initialized = true;
	}
}

/**
	This method logs a string to the log
**/
public void doLog(str theString) {
	if (!initialized) {
		initialize(theString);
	}
	else {
		if (logToConsole) {
			println(theString);
		}
		if (logToFile) {
			appendToFile(logfile, theString + "\r\n");
		}
	}
}

/**
	This method logs an int value to the logger
	@theValue the value to be logged
**/
public void doLog(int theValue) {
	doLog(toString(theValue));
}

/**
	This method activates logging to the console
**/
public void activateToConsole() {
	logToFile = true;
}
 
 /**
	This method activates logging to a file
**/
public void activateToFile() {
	logToFile = true;
}
 