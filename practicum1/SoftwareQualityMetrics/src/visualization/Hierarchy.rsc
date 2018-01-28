module visualization::Hierarchy

import vis::Figure;
import vis::Render;
import IO;
import List;
import vis::KeySym;
import util::Math; 

import calc::Cache;
import visualization::Helper;

alias TreeItem = tuple[calc::Cache::CacheItem item, bool collapsed];
alias TreeStructure = list[TreeItem];

private TreeStructure treeStructure = [];

private int BoxHeight = 200; //default box Height
private int BoxWidth = 200; //default box width
private int MinBoxHeight = 5;
private int MinBoxWidth = 5;  

public void drawPage(){
	println("Draw page");
	
	//loc file = |file:///c:/temp/cach_test.txt|;	
	loc file = |file:///c:/temp/cach_smallsql.txt|;
	calc::Cache::ReadCache(file);
	cache = calc::Cache::GetCache();
	
	//default the items are collapsed excepted the root
	treeStructure = [<item, true> | item <- cache]; 
	//treeStructure[0].collapsed = false;
	
	startDrawing();
}

private void startDrawing(){
	t = createTree();
	render(t);
	
	//c = combo(["A","B","C","D"], void(str s){ println("c: <s>");}, vshrink(0.2));
	//c = box(comboTest(),hshrink(0.2));
	//c = text("Verhouding aantal methoden", vshrink(0.1));
	
	//row = [c, t];
	
	//p = grid([row]);
	
	//render("Hierarchy", vcat([c,t]));		 
}

public Figure comboTest(){
  str state = "A";
  return vcat([ combo(["A","B","C","D"], void(str s){ state = s;}),
                text(str(){return "Current state: " + state ;}, left())
              ]);
}


private Figure createTree(){
	TreeItem rootItem = GetTreeItemsWithParent(0)[0]; //There is always one root element
	//root = box(fillColor(getColor(rootItem.itemType)), popup(getItemInfo(rootItem)));
	root = box( fillColor(visualization::Helper::getColor(rootItem.item.itemType)), 
		hsize(BoxHeight), 
		vsize(BoxWidth), 
		clickProperty(rootItem.item.id), 
		popup(getItemInfo(rootItem.item, [treeItem.item | treeItem <- treeStructure])));
	
	Figures children = [];	
	if (!rootItem.collapsed){
		//println("b: <rootItem.collapsed>, <rootItem.item.id>");
		children = getChildren(rootItem.item.id);
	}
	t = tree(root, children, std(gap(20)));
	
	return t;
}

private list[TreeItem] GetTreeItemsWithParent(int parentId){
	return [item | item <- treeStructure, item.item.parentId == parentId];
}

private FProperty clickProperty(int id){
	return onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers){		
		treeStructure[id-1].collapsed = !treeStructure[id-1].collapsed;		
		//println("click <treeStructure[id-1]>");
		startDrawing();
		
		return true;
	});
}

private Figures getChildren(int parentId){
	items = GetTreeItemsWithParent(parentId);

	Figures children = [];
	for(item <- items){
		//root = box(fillColor(getColor(item.itemType)), popup(getItemInfo(item)));
		int ccHeight = toInt(((item.item.complexity / toReal(treeStructure[0].item.complexity)) * BoxHeight));
		if (ccHeight < MinBoxHeight) {
			ccHeight = MinBoxHeight;
		}
		
		int sizeWidth = toInt(((item.item.size / toReal(treeStructure[0].item.size)) * BoxWidth));
		if (sizeWidth < MinBoxWidth) {
			sizeWidth = MinBoxWidth;
		}
		
		root = box(fillColor(getColor(item.item.itemType)), vsize(ccHeight), hsize(sizeWidth), clickProperty(item.item.id), popup(getItemInfo(item.item, [treeItem.item | treeItem <- treeStructure])));
			
		Figures c = [];
		if (!item.collapsed){
			c = getChildren(item.item.id);
		}
				
		t = tree(root, c, std(size(50)), std(gap(20)));		
		children += t;	
	}
	
	return children; 
} 

/*
public int itemTypeCount(int itemType, int startId){
	items = [treeItem |  treeItem <- treeStructure, treeItem.item.itemType == itemType, treeItem.item.parentId == startId];
	return List::size(items); 
}
*/

public void main(){
	drawPage();
}
