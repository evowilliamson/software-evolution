module visualization::scatter::ScatterDiagram

import vis::Figure;
import vis::Render;
import util::Math;
import vis::examples::New;
import IO;
import List;
import String;
import vis::KeySym;
import visualization::scatter::Types;
import visualization::Helper;

private int DIVISIONS = 10;
private int FONTSIZE_AXIS_METRIC = 8;
private str FONTNAME = "Times-Roman";
private int FONTSIZE_AXIS_TITLE = 11;
private int SIZE_POINT_PARENT = 7;
private int SIZE_POINT_ZOOM = 12;

private ScatterData parentScatterData;
private ScatterData zoomedScatterData;
private Quadrant selectedQuandrant;
private str xAxisTitle;
private str yAxisTitle;

public void main() {

	//render(createScatterDiagrams([DataPoint(arbInt(10), arbInt(10), "bla") | int x <- [1 .. 10]], "Complexity - McCabe values", "Unit Size"));
	render(createScatterDiagrams([DataPoint("bla", 1, 1, "extra"), DataPoint("bla", 10, 1, "extra"), DataPoint("bla", 1, 10, "extra"), 
									DataPoint("bla", 10, 10, "extra")], "Complexity - McCabe values", "Unit Size"));
	
	
//	print(getEuclidianDistance(10, 20, 100, 20));
	
}

public Figure createScatterDiagrams(list[DataPoint] metrics, str xAxisTitle_, str yAxisTitle_) {

	selectedQuandrant = Quadrant(1,1);
	xAxisTitle = xAxisTitle_; 
	yAxisTitle = yAxisTitle_; 
	parentScatterData = createScatterData(metrics);
	updateScatterDataForZoom();

	return vcat([
	 					createScatterDiagram(false),
	 					getZoomedScatter()
					 ], valign(1.0));

}

private Figure getZoomedScatter() {

    return computeFigure (
    	bool () { 
    		updateScatterDataForZoom(); 
    		return true;
    	}, 
    	Figure() {
    		return createScatterDiagram(true);
    	}
    );

} 

private void updateScatterDataForZoom() {

	real minXValueClickedQuadrant = toReal(selectedQuandrant.x - 1) * (toReal(parentScatterData.maxXValue) / toReal(DIVISIONS));
	real maxXValueClickedQuadrant = toReal(selectedQuandrant.x * (toReal(parentScatterData.maxXValue) / toReal(DIVISIONS)));
	real minYValueClickedQuadrant = toReal(parentScatterData.maxYValue - (selectedQuandrant.y * (toReal(parentScatterData.maxYValue) / toReal(DIVISIONS))));
	real maxYValueClickedQuadrant = toReal(parentScatterData.maxYValue - ((selectedQuandrant.y - 1) * (toReal(parentScatterData.maxYValue) / toReal(DIVISIONS))));

	list[DataPoint] zoomedMetrics =  
		[ DataPoint(t.name, t.x, t.y, t.extraInfo)
			| DataPoint t <- parentScatterData.metrics, 
					t.x >= minXValueClickedQuadrant && t.x <= maxXValueClickedQuadrant && 
					t.y >= minYValueClickedQuadrant && t.y <= maxYValueClickedQuadrant 
		];
	
	zoomedScatterData = createScatterDataForZoom(zoomedMetrics, minXValueClickedQuadrant, maxXValueClickedQuadrant, minYValueClickedQuadrant, maxYValueClickedQuadrant);
	
}

private str getMethodInformation() {

	return "Node name: Node\nParent: Parent\nComplexity: 200\nUnit size: 100";
	 
}

private ScatterData createScatterData(list[DataPoint] metrics) {

	int minXValue = 0;
	int maxXValue = 0;
	int maxYValue = 0;
	int minYValue = 0;
	
	if (size(metrics) != 0) {
		list[int] xValues = [metric.x | DataPoint metric <- metrics]; 
		minXValue = min(xValues);
		maxXValue = max(xValues);
		list[int] yValues = [metric.y | DataPoint metric <- metrics];
		maxYValue = max(yValues);
		minYValue = min(yValues);
	}
	

	return ScatterData(metrics, maxXValue, minXValue, maxYValue, minYValue, xAxisTitle, yAxisTitle); 

}

private ScatterData createScatterDataForZoom(list[DataPoint] metrics,
				real minXValueClickedQuadrant,
				real maxXValueClickedQuadrant,
				real minYValueClickedQuadrant,
				real maxYValueClickedQuadrant) {

	int minXValue = 0;
	int maxXValue = 0;
	int maxYValue = 0;
	int minYValue = 0;
	
	if (size(metrics) != 0) {
		minXValue = round(minXValueClickedQuadrant);
		maxXValue = round(maxXValueClickedQuadrant);
		maxYValue = round(maxYValueClickedQuadrant);
		minYValue = round(minYValueClickedQuadrant);
	}

	s = ScatterData(metrics, maxXValue, minXValue, maxYValue, minYValue, xAxisTitle, yAxisTitle);

	return s; 

}

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

public Figure createGrid(ScatterData scatterData, bool isZoom) {

	tuple[real x, real y] average = getAverageXY(scatterData.metrics);
	real diagonalDistance = getDiagonalDistance(scatterData.metrics);
	
	dataPoints = [
				ellipse(
					[
						halign(calculateAlignInGrid(dataPoint.x, scatterData.minXValue, scatterData.maxXValue)), 
						valign(1 - calculateAlignInGrid(dataPoint.y, scatterData.minYValue, scatterData.maxYValue)), resizable(false), 
						size(getPointSize(isZoom)), 
						fillColor("gray"),
						//conditionalPopup(dataPoint, diagonalDistance, average, size(scatterData.metrics))
						popup(getMethodInfo(dataPoint))
					]) | dataPoint <- scatterData.metrics
				];

	print("here");

	emptyGrid = grid([createGridRows(isZoom)]);
	filledGrid = overlay(emptyGrid + dataPoints);
	return filledGrid;
	
} 

private FProperty conditionalPopup(DataPoint dataPoint, real diagonalDistance, tuple[real x, real y] average, int dataPointsSize) {

	if (dataPointsSize < 100 || getEuclidianDistance(average.x, dataPoint.x, average.y, dataPoint.y) > diagonalDistance*0.10) {
		return popup(getMethodInfo(dataPoint));
	}
	else {
		return fillColor("gray");
	}

}

private real getDiagonalDistance(list[DataPoint] dataPoints) {

	list[int] xValues = [metric.x | DataPoint metric <- dataPoints]; 
	maxXValue = max(xValues);
	minXValue = min(xValues);
	list[int] yValues = [metric.y | DataPoint metric <- dataPoints];
	maxYValue = max(yValues);
	minYValue = min(yValues);
	return getEuclidianDistance(minXValue, minYValue, maxXValue, maxYValue);

} 

private real getEuclidianDistance(num px, num py, num qx, num qy) {

	return sqrt(pow(px - qx, 2) + pow(py - qy, 2));

}

private str getMethodInfo(DataPoint dataPoint) {

	return "<dataPoint.name>()\nPackage: <dataPoint.extraInfo>\nComplexity: <dataPoint.x>\nSize: <dataPoint.y>";  
	
}

private tuple[real x, real y] getAverageXY(list[DataPoint] dataPoints) {

	real maxX = 0.0;
	real maxY = 0.0;

	if (size(dataPoints) == 0) {
		return <maxX, maxY>;
		}

	// TODO use accumulator!!!
	for (dataPoint <- dataPoints) {
		maxX += toReal(dataPoint.x);
		maxY += toReal(dataPoint.y);
	}
	
	return <maxX/size(dataPoints), maxY/size(dataPoints)>;

}

private bool showPopup(DataPoint dataPoint, tuple[real x, real y] average) {
	return false;
}
 
private int getPointSize(bool isZoom) {
	if (isZoom) 
		return SIZE_POINT_ZOOM;
	else 
		return SIZE_POINT_PARENT;
}

private list[Figure] createGridRows(bool isZoom) {

	list[Figure] row;
	if (isZoom) {
		row = [box(lineWidth(1.0), 
					lineStyle("dash")) | int x <- [1 .. DIVISIONS + 1]];
		return [vcat(row) | int x <- [1 .. DIVISIONS + 1]];					
	}
	else {
		a = 100;
		return [vcat([box(lineWidth(1.0), 
					lineStyle("dash"), 
					clickScatterQuadrant(x, y)) | int y <- [1 .. DIVISIONS + 1]]) | int x <- [1 .. DIVISIONS + 1]];					
	}

}

private FProperty clickScatterQuadrant(int x, int y) {

	return onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers){
		selectedQuandrant = selectQuadrant(x, y);
		return true;
	});

}

private list[Figure] createXAxisMetricsInformation(ScatterData scatterData) {

	real minReal = toReal(scatterData.minXValue);
	real maxReal = toReal(scatterData.maxXValue);
	real stepSize = ((maxReal-minReal)/toReal(DIVISIONS));
	return [text(formatDecimalString(toString(x)), font(FONTNAME), fontSize(FONTSIZE_AXIS_METRIC), halign(1.0)) | 
				real x <- [minReal + stepSize, minReal + stepSize + stepSize .. maxReal + 1]];
	
}

private list[Figure] createYAxisMetricsInformation(ScatterData scatterData) {

	real minReal = toReal(scatterData.minYValue);
	real maxReal = toReal(scatterData.maxYValue);
	real stepSize = ((maxReal-minReal)/toReal(DIVISIONS));
	
	return [text(formatDecimalString(toString(x)), font(FONTNAME), fontSize(FONTSIZE_AXIS_METRIC), valign(0.0)) | 
				real x <- [maxReal, maxReal - toReal(stepSize) .. minReal]];
	
}

private Figure createXAxisTitle(str theString) {

	return text(theString, font(FONTNAME), fontSize(FONTSIZE_AXIS_TITLE), fontBold(true));
	
}

private list[Figure] createYAxisTitle(str theString) {

	return 	[text(replaceAll(theString, " ", "\n"), font(FONTNAME), fontSize(FONTSIZE_AXIS_TITLE), fontBold(true), valign(0.0))];
	
}

private Quadrant selectQuadrant(int x, int y) {
	return Quadrant(x, y);
}

private real solidLine() {
	return 1.0;
}

private real noLine() {
	return 0.0;
}

private real calculateAlignInGrid(int x, int min, int max) {

	if (max == min) 
		return 1.0;
	else 
		return (toReal(x - min)/toReal(max - min));
	
}

private str formatDecimalString(str theString) {

	str lastLetter = substring(theString, size(theString) - 1); 
	if (lastLetter == ".") {
		return substring(theString, 0, size(theString)) + "0";
	}
	else {
		return theString;
	}	
	
}
