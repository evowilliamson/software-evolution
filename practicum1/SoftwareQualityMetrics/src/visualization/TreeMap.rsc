module visualization::TreeMap

import vis::Figure;
import vis::Render;
import IO;
import List;
import vis::KeySym;
import util::Math; 

import calc::Cache;
import visualization::Helper;

private Cache cache = [];

public void main(){
	drawPage();
}

private void drawPage(){
	//loc file = |file:///c:/temp/cach_test.txt|;	
	loc file = |file:///c:/temp/cach_smallsql.txt|;
	calc::Cache::ReadCache(file);
	cache = calc::Cache::GetCache();
	
	startDrawPage();
}

/**
Draw a tree map, the size of the boxes are the size of the items (package, file) and the color represents the complexity
**/
private void startDrawPage(){
	/*
	t = treemap([box(area(10), fillColor("green")),
				 box(area(20), fillColor("red")),
				 box(area(10), fillColor("white")),
				 box(area(30), fillColor("lightblue"))
				]);
	*/
	application = cache[0];
	children = getChildren(application.id);
	
	t = treemap(children);
	
	render(t);				 
}

private list[CacheItem] GetItemsWithParent(Cache cache, int parentId){
	return [item | item <- cache, item.parentId == parentId];
}

private Figures getChildren(int parentId){
	items = GetItemsWithParent(cache, parentId);

	Figures children = [];
	for(item <- items){
		children += box(area(10), fillColor(visualization::Helper::getColor(item.itemType)));
						
		c = getChildren(item.id);
		t = treemap(c);
					
		children += t;	
	}
	
	return children; 
} 