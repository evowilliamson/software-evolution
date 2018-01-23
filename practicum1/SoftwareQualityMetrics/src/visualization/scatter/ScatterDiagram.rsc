module visualization::scatter::ScatterDiagram

import vis::Figure;
import vis::Render;
import util::Math;
import vis::examples::New;
import IO;
import Set;
import Relation;
import String;

private int DIVISIONS = 10;
private int FONTSIZE_AXIS_METRIC = 8;
private str FONTNAME = "Times-Roman";
private int FONTSIZE_AXIS_TITLE = 11;

public void main() {

	createScatterDiagram();
	
}

private str getMethodInformation() {

	return "Node name: Node\nParent: Parent\nComplexity: 200\nUnit size: 100";
	 
}

private Figure getNodeInformation() {

	return box(text(getMethodInformation),[grow(1.1),resizable(false), pos(100, 100)]);

}

public Figure createGrid(set[tuple[int complexity, int size]] metrics, int minComplexity, int maxComplexity, int minSize, int maxSize) {

	blas = [
						<calculateAlignInGrid(x.complexity, minComplexity, maxComplexity),
						calculateAlignInGrid(x.size, minSize, maxSize)> 
					 | x <- metrics
			];

	print(blas);
	
	ellipses = [
				ellipse(
					[
						halign(calculateAlignInGrid(x.complexity, minComplexity, maxComplexity)), 
						valign(1 - calculateAlignInGrid(x.size, minSize, maxSize)), resizable(false), size(7), 
						fillColor(arbColor),
						mouseOver(getNodeInformation())
					]) | x <- metrics
				];
	emptyGrid = grid([createGridRows()]);
	filledGrid = overlay(emptyGrid + ellipses);
	return filledGrid;
	
} 

private void createScatterDiagram() {

	set[tuple[int complexity, int size]] metrics = {<arbInt(100), arbInt(300)> | int x <- [1 .. 5]};
	
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

private list[Figure] createXAxisMetricsInformation(int min, int max) {

	real minReal = toReal(min);
	real maxReal = toReal(max);
	real stepSize = ((maxReal-minReal)/toReal(DIVISIONS));
	return [text(formatDecimalString(toString(x)), font(FONTNAME), fontSize(FONTSIZE_AXIS_METRIC), halign(1.0)) | 
				real x <- [minReal + stepSize, minReal + stepSize + stepSize .. maxReal + 1]];
	
}

private list[Figure] createYAxisMetricsInformation(int min, max) {

	real minReal = toReal(min);
	real maxReal = toReal(max);
	real stepSize = ((maxReal-minReal)/toReal(DIVISIONS));
	
	return [text(formatDecimalString(toString(x)), font(FONTNAME), fontSize(FONTSIZE_AXIS_METRIC), valign(0.0)) | 
				real x <- [maxReal, maxReal - toReal(stepSize) .. minReal]];
	
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

private real calculateAlignInGrid(int x, int min, int max) {

	if (max == min) 
		return 1.0;
	else 
		return (toReal(x - min)/toReal(max - min));
	
}

private str formatDecimalString(str theString) {

	str lastLetter = substring(theString, size(theString)-1); 
	if (lastLetter == ".") {
		return substring(theString, 0, size(theString)) + "0";
	}
	else {
		return theString;
	}	
	
}

