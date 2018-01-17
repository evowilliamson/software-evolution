module visualization::scatter::Try

import vis::Figure;
import vis::Render;
import util::Math;
import vis::examples::New;
import IO;

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

	scatterGrid = grid([createGridRows()],std(lineWidth(2.0)),std(lineStyle("dot")));
	
	render(box(overlay(scatterGrid + ellipses)));
	
} 

private list[Figure] createGridRows() {

	return [vcat([box() | int x <- [1 .. 10]]) | int x <- [1 .. 10]];

}
