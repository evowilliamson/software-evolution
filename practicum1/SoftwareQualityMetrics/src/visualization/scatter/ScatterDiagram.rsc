module visualization::scatter::ScatterDiagram

import vis::Figure;
import vis::Render;
import util::Math;
import vis::examples::New;
import IO;

private int DIVISIONS = 10;

public void main() {

	generateRandomScatterDiagram();
	
}

private str getMethodInformation() {

	return "Node name: Node\nParent: Parent\nComplexity: 200\nUnit size: 100";
	 
}

private Figure getNodeInformation() {

	return box(text(getMethodInformation),[grow(1.1),resizable(false), pos(100, 100)]);

}

public void generateRandomScatterDiagram(){

	ellipses = [ellipse(
		[halign(arbReal()), valign(arbReal()), resizable(false), size(7), fillColor(arbColor), mouseOver(getNodeInformation())]) | int x <- [1 .. 500]];

	emptyGrid = grid([createGridRows()]);
	filledGrid = overlay(emptyGrid + ellipses);
	canvas = hcat([filledGrid, createYAxisInformation()], gap(1));
	render(vcat([canvas, createXAxisInformation()], gap(1)));
	
} 

private Figure createXAxisInformation() {

	list[Figure] boxes = 
			box(hshrink(((toReal(DIVISIONS) - 1.0)/100.0)/2.0), lineWidth(noLine())) + 
			[box(text("test"), lineWidth(noLine())) | int x <- [1 .. DIVISIONS]] + 
			box(hshrink(((toReal(DIVISIONS) - 1.0)/100.0)/2.0), lineWidth(noLine()));
	box_ = hcat(boxes + box(hshrink(1.0/toReal(DIVISIONS + 1)), lineWidth(noLine())));
	return overlay([box_], vshrink(1.0/(toReal(DIVISIONS) * 2.0)));
	
}

private Figure createXAxisInformation2() {

	list[Figure] boxes = [box(text("test"), lineWidth(solidLine())) | int x <- [1 .. DIVISIONS + 1]];
	box_ = hcat(boxes + box(text("test"), lineWidth(solidLine())));
	return overlay([box_], vshrink(1.0/(toReal(DIVISIONS) * 2.0)));
	
}

private Figure createYAxisInformation() {

	list[Figure] boxes = [box(text("test", halign(0.1)), lineWidth(0.0)) | int x <- [1 .. DIVISIONS]]; 
	box_ = vcat(box(vshrink(1.0/(toReal(DIVISIONS) * 2.0)), lineWidth(noLine())) + 
			boxes + box(vshrink(1.0/(toReal(DIVISIONS) * 2.0)), lineWidth(noLine())));
	return overlay([box_], hshrink((toReal(DIVISIONS) - 1.0)/100.0));
	
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

