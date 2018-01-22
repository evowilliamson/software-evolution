module visualization::scatter::ScatterDiagram

import vis::Figure;
import vis::Render;
import util::Math;
import vis::examples::New;
import IO;

private int DIVISIONS = 10;
private int FONTSIZE_AXIS_METRIC = 8;
private str FONTNAME = "Times-Roman";
private int FONTSIZE_AXIS_TITLE = 11;

public void main() {

	createScatterDiagram();
	//mondriaan();
	
}

private str getMethodInformation() {

	return "Node name: Node\nParent: Parent\nComplexity: 200\nUnit size: 100";
	 
}

private Figure getNodeInformation() {

	return box(text(getMethodInformation),[grow(1.1),resizable(false), pos(100, 100)]);

}

public Figure createGrid(){

	ellipses = [ellipse(
		[halign(arbReal()), valign(arbReal()), resizable(false), size(7), fillColor(arbColor), mouseOver(getNodeInformation())]) | int x <- [1 .. 500]];

	emptyGrid = grid([createGridRows()]);
	filledGrid = overlay(emptyGrid + ellipses);
	//canvas = hcat([filledGrid, createYAxisInformation()], gap(solidLine()));
	//render(vcat([canvas, createXAxisInformation()], gap(solidLine())));
	return filledGrid;
	
} 

private void createScatterDiagram() {
	render(box(grid([
			[
				box(createGrid(), vshrink(0.95), hshrink(0.9)),
				hcat([text("1"),text("1")], vshrink(0.95))
			],
	 		[
	 			vcat([
	 				hcat(createXAxisMetricsInformation(), valign(0.0)), 
	 				createXAxisTitle()
	 				], hshrink(0.9)),
	 			text("1")
	 		]
		])));
}


public void mondriaan(){
	// Painting by Piet Mondriaan: Composition II in Red, Blue, and Yellow, 1930
	render(grid([
			[
				vcat([box(),box()],hshrink(0.2),vshrink(0.8))
				,box(vshrink(0.8))
			],
	 		[
	 			box(hshrink(0.2)),
	 			hcat([
	 				  box(hshrink(0.9)),
	 				  vcat([box(),box()])
					 ])
	 		]
		]));
} 

private Figure createXAxisInformationOld() {

	list[Figure] boxes = 
			box(hshrink(((toReal(DIVISIONS) - 1.0)/100.0)/2.0), lineWidth(noLine())) + 
			[box(text("test", FONTSIZE_AXIS_METRIC(FONTSIZE_AXIS_METRIC)), lineWidth(noLine())) | int x <- [1 .. DIVISIONS]] + 
			box(hshrink(((toReal(DIVISIONS) - 1.0)/100.0)/2.0), lineWidth(noLine()));
	box_ = hcat(boxes + box(hshrink((1.0/toReal(DIVISIONS + 1)/3.0)), lineWidth(noLine())));
	return overlay([box_], vshrink(1.0/(toReal(DIVISIONS) * 2.0)));
	
}

private list[Figure] createXAxisMetricsInformation() {

	list[Figure] boxes = [text(toString(x), font(FONTNAME), fontSize(FONTSIZE_AXIS_METRIC), halign(1.0)) | int x <- [1 .. 11]]; 
	return boxes;
	
}

private Figure createXAxisTitle() {

	return text("Complexity - McCabe values", font(FONTNAME), fontSize(FONTSIZE_AXIS_TITLE), fontBold(true));
	
}

private Figure createYAxisLegendInfo() {

	list[Figure] boxes = [box(text("test", halign(0.1), FONTSIZE_AXIS_METRIC(FONTSIZE_AXIS_METRIC)), lineWidth(1.0), hshrink(0.1)) | int x <- [1 .. DIVISIONS]]; 
	box_ = vcat(boxes);
	return overlay([box_], hshrink((toReal(DIVISIONS) - 1.0)/500.0));
	
}

private Figure createYAxisInformation() {

	list[Figure] boxes = [box(text("test", halign(0.1), FONTSIZE_AXIS_METRIC(FONTSIZE_AXIS_METRIC)), lineWidth(1.0)) | int x <- [1 .. DIVISIONS]]; 
	box_ = vcat(box(vshrink(1.0/(toReal(DIVISIONS) * 2.0)), lineWidth(noLine())) + 
			boxes + box(vshrink(1.0/(toReal(DIVISIONS) * 2.0)), lineWidth(noLine())));
	return overlay([box_], hshrink((toReal(DIVISIONS) - 1.0)/300.0));
	
}

private list[Figure] createGridRows() {

	row = [box(lineWidth(solidLine())) | int x <- [1 .. DIVISIONS + 1]];
	return [vcat(row) | int x <- [1 .. DIVISIONS + 1]];

}

private real solidLine() {
	return 1.0;
}

private real noLine() {
	return 0.0;
}

