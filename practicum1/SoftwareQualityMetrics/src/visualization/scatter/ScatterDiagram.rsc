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

private int DIVISIONS = 10;
private int FONTSIZE_AXIS_METRIC = 8;
private str FONTNAME = "Times-Roman";
private int FONTSIZE_AXIS_TITLE = 11;
private int SIZE_POINT_PARENT = 7;
private int SIZE_POINT_ZOOM = 12;

private ScatterData parentScatterData;
private ScatterData zoomedScatterData;
private Quadrant selectedQuandrant = Quadrant(1,1);
private str xAxisTitle;
private str yAxisTitle;

public void main() {

	render(createScatterDiagrams([DataPoint(arbInt(100), arbInt(300)) | int x <- [1 .. 1000]], "Complexity - McCabe values", "Unit Size"));
	
}

public Figure createScatterDiagrams(list[DataPoint] metrics, str xAxisTitle_, str yAxisTitle_) {

	xAxisTitle = xAxisTitle_; 
	yAxisTitle = yAxisTitle_; 
	parentScatterData = createScatterData(metrics);
	updateScatterData();

	return vcat([
	 					createScatterDiagram(false),
	 					getZoomedScatter()
					 ], valign(1.0));

}

private Figure getZoomedScatter() {

    return computeFigure (
    	bool () { 
    		updateScatterData(); 
    		return true;
    	}, 
    	Figure() {
    		return createScatterDiagram(true);
    	}
    );

} 

private void updateScatterData() {
	
	int minXValueClickedQuadrant = toInt((selectedQuandrant.x - 1) * (toReal(parentScatterData.maxXValue) / toReal(DIVISIONS)));
	int maxXValueClickedQuadrant = toInt(selectedQuandrant.x * (toReal(parentScatterData.maxXValue) / toReal(DIVISIONS)));
	int minYValueClickedQuadrant = toInt(parentScatterData.maxYValue - (selectedQuandrant.y * (toReal(parentScatterData.maxYValue) / toReal(DIVISIONS))));
	int maxYValueClickedQuadrant = toInt(parentScatterData.maxYValue - ((selectedQuandrant.y - 1) * (toReal(parentScatterData.maxYValue) / toReal(DIVISIONS))));

	list[DataPoint] zoomedMetrics =  
		[ DataPoint(t.x, t.y)
			| DataPoint t <- parentScatterData.metrics, 
					t.x >= minXValueClickedQuadrant && t.x <= maxXValueClickedQuadrant && 
					t.y >= minYValueClickedQuadrant && t.y <= maxYValueClickedQuadrant 
		];

	zoomedScatterData = createScatterData(zoomedMetrics);

}

private str getMethodInformation() {

	return "Node name: Node\nParent: Parent\nComplexity: 200\nUnit size: 100";
	 
}

private Figure getNodeInformation() {

	return box(text(getMethodInformation),[grow(1.1),resizable(false)]);

}

private ScatterData createScatterData(list[DataPoint] metrics) {

	list[int] xValues = [metric.x | DataPoint metric <- metrics]; 
	int maxXValue = max(xValues);
	int minXValue = min(xValues);
	list[int] yValues = [metric.y | DataPoint metric <- metrics];
	int maxYValue = max(yValues);
	int minYValue = min(yValues);
	return ScatterData(metrics, maxXValue, minXValue, maxYValue, minYValue, xAxisTitle, yAxisTitle);

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

	dataPoints = [
				ellipse(
					[
						halign(calculateAlignInGrid(metric.x, scatterData.minXValue, scatterData.maxXValue)), 
						valign(1 - calculateAlignInGrid(metric.y, scatterData.minYValue, scatterData.maxYValue)), resizable(false), 
						size(getPointSize(isZoom)), 
						fillColor("gray")
					]) | metric <- scatterData.metrics
				];
	emptyGrid = grid([createGridRows(isZoom)]);
	filledGrid = overlay(emptyGrid + dataPoints);
	return filledGrid;
	
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
