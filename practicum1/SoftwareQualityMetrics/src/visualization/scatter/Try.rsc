module visualization::scatter::Try

import vis::examples::New;
import vis::Figure;
import vis::Render;
import vis::examples::Outline;
//import vis::examples::MouseOverSpiral;
import util::Math;
import IO;

public void main() {

	a = ellipse([halign(0.5), valign(0.6), resizable(false), size(5), fillColor(arbColor)]);
	b = ellipse([halign(0.7), valign(0.6), resizable(false), size(5), fillColor(arbColor)]);
	println(a);
	render(box(overlay([a,b])));

//	doMouseOverSpiral();	
	
}


/*

_ellipse(
	_text("0",[]),
	[
		halign(0.5),
		valign(0.6),
		unpack([hresizable(false),vresizable(false)]),
		unpack([hsize(100),vsize(100)]),
		fillColor(-16134609)
	]
)


*/

public Figure mouseOverSpiral(int n,real radius, real increase,real radiusIncrease,real curAngle){
	list[FProperty] props = (n == 0) ? 
		[] : 
		[mouseOver(mouseOverSpiral(n-1,radius + radiusIncrease,increase,radiusIncrease,curAngle+increase))];
	r = max(0.5,radius);
	h = sin(curAngle) * radius + 0.5;
	v = cos(curAngle) * radius + 0.5;
	println(h);
	println(v);
	return ellipse(text("<n>"), [*props, halign(h), valign(v), resizable(false), size(100), fillColor(arbColor())]);
	
	
	
	
}
	
public void doMouseOverSpiral(){
	spiral = mouseOverSpiral(0,0.1,0.15,0.001,0.0);
	e = ellipse(text("Move mouse over me!"),fillColor("red"),shrink(0.5),mouseOver(spiral));
	println(spiral);
	render(e);
}



