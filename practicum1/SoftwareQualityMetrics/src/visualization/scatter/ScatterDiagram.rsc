module visualization::scatter::ScatterDiagram

import vis::Figure;
import vis::Render;
import util::Math;
import vis::examples::New;
import IO;
import Set;
import Relation;

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

public Figure createGrid(set[tuple[int complexity, int size]] metrics, int minComplexity, int maxComplexity, int minSize, int maxSize) {

	blas = [
						<((toReal(x.complexity - minComplexity)/toReal(maxComplexity - minComplexity))),
						((toReal(x.size - minSize)/toReal(maxSize - minSize)))> 
					 | x <- metrics
			];

	print(blas);
	
	ellipses = [
				ellipse(
					[
						halign((toReal(x.complexity - minComplexity)/toReal(maxComplexity - minComplexity))), 
						valign((toReal(x.size - minSize)/toReal(maxSize - minSize))), resizable(false), size(7), 
						fillColor(arbColor),
						mouseOver(getNodeInformation())
					]) | x <- metrics
				];
	emptyGrid = grid([createGridRows()]);
	filledGrid = overlay(emptyGrid + ellipses);
	//canvas = hcat([filledGrid, createYAxisInformation()], gap(solidLine()));
	//render(vcat([canvas, createXAxisInformation()], gap(solidLine())));
	return filledGrid;
	
} 

private void createScatterDiagram() {

	set[tuple[int complexity, int size]] metrics = {<arbInt(100), arbInt(300)> | int x <- [1 .. 4]};
	
	set[int] complexities = domain(metrics); 
	int maxComplexity = max(complexities);
	int minComplexity = min(complexities);
	set[int] sizes = range(metrics); 
	int maxSize = max(sizes);
	int minSize = min(sizes);
	
	print(toList(metrics));

	render(box(grid([
			[
				box(createGrid(metrics, minComplexity, maxComplexity, minSize, maxSize), vshrink(0.95), hshrink(0.95)),
				hcat([
					vcat(createYAxisMetricsInformation(minSize, maxSize), halign(0.0)),
					vcat(createYAxisTitle(), halign(0.0))
					], vshrink(0.95), halign(0.0))
			],
	 		[
	 			vcat([
	 				hcat(createXAxisMetricsInformation(minComplexity, maxComplexity), valign(0.0)), 
	 				createXAxisTitle()
	 				], hshrink(0.95))
	 		]
		])));
}

private list[Figure] createXAxisMetricsInformation(int minComplexity, int maxComplexity) {

	maxComplexity = ((maxComplexity / 10) * 10) + 10;
	return [text(toString(x), font(FONTNAME), fontSize(FONTSIZE_AXIS_METRIC), halign(1.0)) | int x <- [maxComplexity/10, (maxComplexity/10)*2 ..  maxComplexity + 1]];
	
}

private list[Figure] createYAxisMetricsInformation(int minSize, maxSize) {

	return [text(toString(x), font(FONTNAME), fontSize(FONTSIZE_AXIS_METRIC), valign(0.0)) | int x <- [maxSize, maxSize - (maxSize/10) .. (maxSize/10) - 1]];
	
}

private Figure createXAxisTitle() {

	return text("Complexity - McCabe values", font(FONTNAME), fontSize(FONTSIZE_AXIS_TITLE), fontBold(true));
	
}

private list[Figure] createYAxisTitle() {

	return 	[
		text("Unit", font(FONTNAME), fontSize(FONTSIZE_AXIS_TITLE), fontBold(true), valign(1.0)), 
		text("Size", font(FONTNAME), fontSize(FONTSIZE_AXIS_TITLE), fontBold(true), valign(0.0))
			];
	
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

