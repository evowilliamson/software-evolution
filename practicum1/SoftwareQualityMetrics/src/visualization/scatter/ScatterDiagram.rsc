module visualization::scatter::ScatterDiagram

import vis::Figure;
import vis::Render;
import util::Math;
import vis::examples::New;
import IO;
import Set;
import Relation;
import String;
import vis::KeySym;
import visualization::scatter::Types;

private int DIVISIONS = 10;
private int FONTSIZE_AXIS_METRIC = 8;
private str FONTNAME = "Times-Roman";
private int FONTSIZE_AXIS_TITLE = 11;

public void main() {

	createScatterDiagrams();
	
}

private void createScatterDiagrams() {

	render(
	 			vcat([
	 					createScatterDiagram(1),
	 					getZoomedScatter()
					 ], valign(1.0))
		);

}

private Figure getZoomedScatter() {

    return computeFigure (bool () { return true;}, Figure() {
		return createScatterDiagram(1);
    });

} 

private str getMethodInformation() {

	return "Node name: Node\nParent: Parent\nComplexity: 200\nUnit size: 100";
	 
}

private Figure getNodeInformation() {

	return box(text(getMethodInformation),[grow(1.1),resizable(false)]);

}

public Figure createGrid(ScatterData scatterData) {

	dataPoints = [
				ellipse(
					[
						halign(calculateAlignInGrid(metric.x, scatterData.minXValue, scatterData.maxXValue)), 
						valign(1 - calculateAlignInGrid(metric.y, scatterData.minYValue, scatterData.maxYValue)), resizable(false), size(5), 
						fillColor(arbColor)//,
						//mouseOver(getNodeInformation())
					]) | metric <- scatterData.metrics
				];
	emptyGrid = grid([createGridRows()]);
	filledGrid = overlay(emptyGrid + dataPoints);
	return filledGrid;
	
} 

private ScatterData createScatterData(set[tuple[int x, int y]] metrics, str xAxisTitle, str yAxisTitle) {

	set[int] xValues = domain(metrics); 
	int maxXValue = max(xValues);
	int minXValue = min(xValues);
	set[int] yValues = range(metrics); 
	int maxYValue = max(yValues);
	int minYValue = min(yValues);
	return ScatterData(metrics, maxXValue, minXValue, maxYValue, minYValue, xAxisTitle, yAxisTitle);

}

public Figure createScatterDiagram(int level) {

	scatterData = createScatterData({<arbInt(100), arbInt(300)> | int x <- [1 .. 1000]}, "Complexity - McCabe values", "Unit Size");
	
	return(box(grid([
			[
				box(createGrid(scatterData), vshrink(0.95), hshrink(0.95)),
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

private list[Figure] createGridRows() {

	row = [box(lineWidth(1.0), 
				lineStyle("dash"), 
				onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
					s = "<butnr>";
					print(s);
					return true;
				})) | int x <- [1 .. DIVISIONS + 1]];
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

	str lastLetter = substring(theString, size(theString) - 1); 
	if (lastLetter == ".") {
		return substring(theString, 0, size(theString)) + "0";
	}
	else {
		return theString;
	}	
	
}


public void bla() {
    bool redraw = false;
    str boxWidthProp = "";

    Figure topBar = hcat([text("Width"), combo(["1", "2"], void(str s){ boxWidthProp = s; }, hshrink(0.1))
    , button("Redraw", void() {redraw = true; }, resizable(false))], vshrink(0.05), hgap(5));

    Figure getTreemap() {
    return computeFigure(bool () { bool temp = redraw; redraw = false; return temp; }, Figure() {
                int sz = 20;
                if (boxWidthProp == "2")
                    sz = 100;
                b = box(size(sz, sz), fillColor("Red"), resizable(false));
                t = text(str() {return "w: <sz>; prop: <boxWidthProp>"; });
                Figures boxes = [];
                boxes += b;
                boxes += t;

                //return pack(boxes, std(gap(5)));
                return vcat([t,b]);
            });
    }

    vc = vcat([topBar, getTreemap()]);
    render(vc);
}
