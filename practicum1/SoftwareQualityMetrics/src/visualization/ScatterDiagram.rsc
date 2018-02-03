module visualization::ScatterDiagram

/*

@author Ivo Willemsen
This module is in an implementation of a 'interactive' scatter plot matrix diagram. It's a stand-alonse module and can be
use by any client that adheres to the interface method createScatterDiagrams().

It provides the drawing of two scatter diagrams: The first scatter is diagram is the parent scatter, which contains all the 
datapoints that are passed to it. The scatter diagram contains 10x10 quadrants. The user can zoom into a certain quadrant 
by clicking on it. The child scatter will then fill with only the data points that are present in the clicked quadrant. This will enable 
to zoom into the portion of the parent scatter and look at the data at more detail.
*/

import vis::Figure;
import vis::Render;
import util::Math;
import vis::examples::New;
import IO;
import List;
import String;
import vis::KeySym;
import visualization::Types;
import visualization::Helper;

// Constants definitions
private int DIVISIONS = 10;
private int FONTSIZE_AXIS_METRIC = 8;
private str FONTNAME = "Times-Roman";
private int FONTSIZE_AXIS_TITLE = 11;
private int SIZE_POINT_PARENT = 7;
private int SIZE_POINT_ZOOM = 12;

// Private data to this module
private ScatterData parentScatterData;
private ScatterData zoomedScatterData;
private Quadrant selectedQuandrant;
private str xAxisTitle;
private str yAxisTitle;
private Figure zoomedScatter;
private bool clickedScatter = true;

/**
	Method for testing purposes
**/
public void main() {

	render(createScatterDiagrams([DataPoint("bla", 1.0, 1.0, 1.0, "extra"), DataPoint("bla", 10.0, 1.0, 1.0, "extra"), DataPoint("bla", 1.0, 10.0, 1.0, "extra"), 
									DataPoint("bla", 10.0, 10.0, 1.0, "extra")], "Complexity - McCabe values", "Unit Size"));
	
	
}

/**
	This method serves as an interface to the caller and it will encapsulat the drawing of the 
	two scatter diagrams
	@metrics: a list of datapoints of type DataPoint
	@xAxisTitle_: the title of the x-axis
	@yAxisTitle_: the title of the y-axis
	returns: 	an object of type Figure that represents the container objects that contains the two 
				scatter diagrams
**/	
public Figure createScatterDiagrams(list[DataPoint] metrics, str xAxisTitle_, str yAxisTitle_) {

	selectedQuandrant = Quadrant(1,1);
	xAxisTitle = xAxisTitle_; 
	yAxisTitle = yAxisTitle_; 
	parentScatterData = createScatterData(metrics);
	updateScatterDataForZoom();

	return vcat([	createScatterDiagram(false),
	 				getZoomedScatter()
				], valign(1.0));

}

/**
	Method that creates the zoomed scatter diagram
	returns: an object of type Figure that represents the scatter diagram
**/
private Figure getZoomedScatter() {

	/* 	Use a dynamically computed figure. The reason for this being that this is a independent module. We don't
		want to render the whole encapsulating Figure, because that would require a call from the ScatterDiagram
		module to the encapsulating Figure, which would obviously violate basic design patterns */
    return computeFigure (
    	bool () { 
    		if (clickedScatter) {
    			// only update if clicked, don't react on other events, like mouse movement
    			updateScatterDataForZoom();
    			return true;
    		}
    		else {
    			return false;
    		}
    	}, 
    	Figure() {
    		if (clickedScatter) {
    			// only update if clicked, don't react on other events, like mouse movement
    			zoomedScatter = createScatterDiagram(true);
    			// reset flag
    			clickedScatter = false;
    		} 
	    	return zoomedScatter;
    	}
    );

} 

/**
	Method that updates the data for the zoom scatter diagram
**/
private void updateScatterDataForZoom() {

	// Determine that rectangle that represents the clicked quadrant
	real minXValueClickedQuadrant = toReal(selectedQuandrant.x - 1) * (toReal(parentScatterData.maxXValue) / toReal(DIVISIONS));
	real maxXValueClickedQuadrant = toReal(selectedQuandrant.x * (toReal(parentScatterData.maxXValue) / toReal(DIVISIONS)));
	real minYValueClickedQuadrant = toReal(parentScatterData.maxYValue - (selectedQuandrant.y * (toReal(parentScatterData.maxYValue) / toReal(DIVISIONS))));
	real maxYValueClickedQuadrant = toReal(parentScatterData.maxYValue - ((selectedQuandrant.y - 1) * (toReal(parentScatterData.maxYValue) / toReal(DIVISIONS))));

	// Now only consider the datapoints that fall into the clicked quadrant
	list[DataPoint] zoomedMetrics =  
		[ DataPoint(t.name, t.x, t.y, 0.0, t.extraInfo)
			| DataPoint t <- parentScatterData.metrics, 
					t.x >= minXValueClickedQuadrant && t.x <= maxXValueClickedQuadrant && 
					t.y >= minYValueClickedQuadrant && t.y <= maxYValueClickedQuadrant 
		];
	
	// Determine the min and max z values. Input for that are the zoomed points!
	real minZ = (0.0 | max(it, e.z) | DataPoint e <- zoomedMetrics);
	real maxZ = (0.0 | min(it, e.z) | DataPoint e <- zoomedMetrics);
	
	zoomedScatterData = createScatterDataForZoom(zoomedMetrics, minXValueClickedQuadrant, maxXValueClickedQuadrant, minYValueClickedQuadrant, 
							minZ, maxZ, maxYValueClickedQuadrant);
	
}

/**	
	Method that creates the ScatterData object based on the list of datapoints. Basically it calculates the max and min values of the data points
	@metrics: the list of data points
	returns: an object of ScatterData that has a list of the datapoints and the min and max values
**/
private ScatterData createScatterData(list[DataPoint] metrics) {

	real minXValue = 0.0;
	real maxXValue = 0.0;
	real maxYValue = 0.0;
	real minYValue = 0.0;
	real maxZValue = 0.0;
	real minZValue = 0.0;
	
	if (size(metrics) != 0) {
		list[real] xValues = [metric.x | DataPoint metric <- metrics]; 
		minXValue = min(xValues);
		maxXValue = max(xValues);
		list[real] yValues = [metric.y | DataPoint metric <- metrics];
		maxYValue = max(yValues);
		minYValue = min(yValues);
		list[real] zValues = [metric.z | DataPoint metric <- metrics];
		maxZValue = max(zValues);
		minZValue = min(zValues);
	}
	

	return ScatterData(metrics, maxXValue, minXValue, maxYValue, minYValue, maxZValue, minZValue, xAxisTitle, yAxisTitle); 

}

/**
	Same method as before, but then to be used only in case of a zoom scatter diagram (controlled by caller)
**/
private ScatterData createScatterDataForZoom(list[DataPoint] metrics,
				real minXValueClickedQuadrant,
				real maxXValueClickedQuadrant,
				real minYValueClickedQuadrant,
				real maxYValueClickedQuadrant,
				real minYValueClickedQuadrant,
				real maxYValueClickedQuadrant) {

	real minXValue = 0.0;
	real maxXValue = 0.0;
	real maxYValue = 0.0;
	real minYValue = 0.0;
	real maxZValue = 0.0;
	real minZValue = 0.0;
	
	if (size(metrics) != 0) {
		minXValue = minXValueClickedQuadrant;
		maxXValue = maxXValueClickedQuadrant;
		maxYValue = maxYValueClickedQuadrant;
		minYValue = minYValueClickedQuadrant;
		maxZValue = maxZValueClickedQuadrant;
		minZValue = minZValueClickedQuadrant;
	}

	return ScatterData(metrics, maxXValue, minXValue, maxYValue, minYValue, maxZValue, minZValue, xAxisTitle, yAxisTitle); 

}

/**
	This method creates the scatter diagram Figure
	
	A scatter diagram is built up of 10 quadrant and a set of data points. The quadrants are drawn by creating boxes with 
	a line style of "dash" and a set of Ellipse objects that represent the data points. These ellipses and boxes
	are drawn by overlaying them. 
	
	@isZoom: 	true in case that the zoomed scatter diagram should be created, false if the parent scatter diagram
				must be created
	@returns: 	an object of type Figure that represents the created scatter diagram
**/
public Figure createScatterDiagram(bool isZoom) {

	ScatterData scatterData = parentScatterData;
	if (isZoom) {
		scatterData = zoomedScatterData;
	}

	return(box(grid([
			[
				box(createGrid(scatterData, isZoom), vshrink(0.95), hshrink(0.95)),
				hcat([
					vcat(createYAxisMetricsInformation(scatterData), halign(0.0)),
					vcat(createYAxisTitle(scatterData.yAxisTitle), halign(0.0))
					], vshrink(0.95), halign(0.0))
			],
	 		[
	 			vcat([
	 				hcat(createXAxisMetricsInformation(scatterData), valign(0.0)), 
	 				createXAxisTitle(scatterData.xAxisTitle)
	 				], hshrink(0.95))
	 		]
		])));
		
}

/**
	This method creates the ellipses and the boxes that represent the quadrants of the scatter diagram
**/
public Figure createGrid(ScatterData scatterData, bool isZoom) {

	// Create the ellipses that represent the data points
	dataPoints = [
				ellipse(
					[
						halign(calculateAlignInGrid(dataPoint.x, scatterData.minXValue, scatterData.maxXValue)), 
						valign(1 - calculateAlignInGrid(dataPoint.y, scatterData.minYValue, scatterData.maxYValue)), resizable(false), 
						size(getPointSize(isZoom)), 
						createDataPointColor("green", (dataPoint.z - scatterData.minZValue)/(scatterData.maxZValue - scatterData.minZValue)),
						popup(getMethodInfo(dataPoint))
					]) | dataPoint <- scatterData.metrics
				];
				
	// Creatae the empty grid. The grid contains dashed boxes
	emptyGrid = grid([createDashedGridBoxes(isZoom)]);
	
	// Now overlay the grid and the ellipses
	filledGrid = overlay(emptyGrid + dataPoints);
	return filledGrid;
	
} 

private FProperty createDataPointColor(str dataPointColor, real value_) {

	from = color("white");
	to = color(dataPointColor);
	return fillColor(interpolateColor(from, to, value_));

}

/**
	This method creates the boxes inside the scatter grid
	@isZoom: 	true in case that the zoomed scatter diagram should be created, false if the parent scatter diagram
				must be created
	returns: 	a list of dahsed grid boxes	
**/
private list[Figure] createDashedGridBoxes(bool isZoom) {

	list[Figure] row;
	if (isZoom) {
		// In case of a zoom scatter, there is no further interactivity.. you cannot click further
		row = [box(lineWidth(1.0), 
					lineStyle("dash")) | int x <- [1 .. DIVISIONS + 1]];
		return [vcat(row) | int x <- [1 .. DIVISIONS + 1]];					
	}
	else {
		// In case of a parent scatter, add the logic that handles the clicking on the quadrant
		return [vcat([box(lineWidth(1.0), 
					lineStyle("dash"), 
					clickScatterQuadrant(x, y)) | int y <- [1 .. DIVISIONS + 1]]) | int x <- [1 .. DIVISIONS + 1]];					
	}

}

/**
	Method that prints info about the method. This method is invoked when the 
	user hovers over the data point
	@dataPoint: 	object of type dataPoint that contains information about the position of the data point, the full qualified name
					of its parent and the name of the method itself
	returns: 		the construced string with all the info
**/
private str getMethodInfo(DataPoint dataPoint) {

	for (d <- [] + dataPoint) {
		print(" \\hline smallsql&<d.extraInfo>.<d.name>()&<d.x>&<d.y>\\\\\n");
	}

	return "<dataPoint.name>()\nPackage: <dataPoint.extraInfo>\nComplexity: <dataPoint.x>\nSize: <dataPoint.y>";  
	
}

/**
	This method determines the size of the data point.
	@isZoom: 	In case it's true, a zoom scatter is the context, we want a just a bit bigger dot for the data pinit. 
				If false, a parent scatter, a normal dot will be fine
**/
private int getPointSize(bool isZoom) {
	if (isZoom) 
		return SIZE_POINT_ZOOM;
	else 
		return SIZE_POINT_PARENT;
}

/**
	Method that is called when the user clicks on a quadrant
	@x: The x value that represents the quadrant on the horizontal scale
	@y: The y value that represents the quadrant on the horizontal scale
	For example: (1,1) represents the lower right corner of the scatter diagram
	returns: the logic itself
**/
private FProperty clickScatterQuadrant(int x, int y) {

	return onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers){
		selectedQuandrant = selectQuadrant(x, y);
		// Set flag to indicate that the quadrant was clicked
		clickedScatter = true;
		return true;
	});

}

/**
	Create a list of figures that will represent the X-axis information, i.e., the title of
	the x-axis and the values that indicate the value of the box boundaries inside the grid
	@scatterData: the object that contains all the information of the scatter diagram
	returns: a list of figure that represnt Y-Axis information
**/
private list[Figure] createXAxisMetricsInformation(ScatterData scatterData) {

	real minReal = toReal(scatterData.minXValue);
	real maxReal = toReal(scatterData.maxXValue);
	real stepSize = ((maxReal-minReal)/toReal(DIVISIONS));
	return [text(formatDecimalString(toString(x)), font(FONTNAME), fontSize(FONTSIZE_AXIS_METRIC), halign(1.0)) | 
				real x <- [minReal + stepSize, minReal + stepSize + stepSize .. maxReal + 1]];
	
}

/**
	Create a list of figures that will represent the Y-axis information, i.e., the title of
	the y-axis and the values that indicate the value of the box boundaries inside the grid
	@scatterData: the object that contains all the information of the scatter diagram
	returns: a list of figure that represnt Y-Axis information
**/
private list[Figure] createYAxisMetricsInformation(ScatterData scatterData) {

	real minReal = toReal(scatterData.minYValue);
	real maxReal = toReal(scatterData.maxYValue);
	real stepSize = ((maxReal-minReal)/toReal(DIVISIONS));
	
	return [text(formatDecimalString(toString(x)), font(FONTNAME), fontSize(FONTSIZE_AXIS_METRIC), valign(0.0)) | 
				real x <- [maxReal, maxReal - toReal(stepSize) .. minReal]];
	
}

/**
	Method that creates the X-axis title
	@theString: the string of the title
**/
private Figure createXAxisTitle(str theString) {

	return text(theString, font(FONTNAME), fontSize(FONTSIZE_AXIS_TITLE), fontBold(true));
	
}

/**
	Method that creates the Y-axis title
	@theString: the string of the title
**/
private list[Figure] createYAxisTitle(str theString) {

	return 	[text(replaceAll(theString, " ", "\n"), font(FONTNAME), fontSize(FONTSIZE_AXIS_TITLE), fontBold(true), valign(0.0))];
	
}

/**
	Create a Quadrant object based on x and y value
	@x: 		x value
	@y: 		y value
	returns: 	the Quadrant object
**/
private Quadrant selectQuadrant(int x, int y) {
	return Quadrant(x, y);
}

/**
	Method that calculates the align in the grid, the position where the point should
	be placed on a scale of 0 to 1.
	@x: 		x value
	@min: 		min boundary of the grid
	@max		max boundary of the grid
	
**/
private real calculateAlignInGrid(real x, real min, real max) {

	if (max == min) 
		return 1.0;
	else 
		return (toReal(x - min)/toReal(max - min));
	
}
/**
	Helper method to format a decimal
	@theString: the string to be formatted
	returns: 	the formatted string
**/
private str formatDecimalString(str theString) {

	str lastLetter = substring(theString, size(theString) - 1); 
	if (lastLetter == ".") {
		return substring(theString, 0, size(theString)) + "0";
	}
	else {
		return theString;
	}	
	
}
