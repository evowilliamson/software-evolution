module visualization::scatter::Try

import vis::Figure;
import vis::Render;
import util::Math;

public void main() {

	generateRandomScatter();
	
}


public void generateRandomScatter() {

	ellipses = [ ellipse(
		[halign(arbReal()), valign(arbReal()), resizable(false), size(7), fillColor(arbColor), mouseOver(box(text("bla\nfsdfdf\n\fdhjfhdf"),grow(1.2),resizable(false)))]) | int x <- [1 .. 1000]];
	
	render(box(overlay(ellipses), [halign(0.2), valign(0.2), resizable(false), size(300), fillColor("white")]));

}



