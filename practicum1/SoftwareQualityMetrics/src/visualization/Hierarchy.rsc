module visualization::Hierarchy

import vis::Figure;
import vis::Render;
import IO;
import List;

import calc::Cache;

public void drawTree(){
	println("Draw tree");
	
	//loc file = |file:///c:/temp/cach_test.txt|;	
	loc file = |file:///c:/temp/cach_smallsql.txt|;
	calc::Cache::ReadCache(file);
	calc::Cache::CacheItem rootItem = calc::Cache::GetCachItemsWithParent(0)[0]; //There is always one root element
	
	root = box(fillColor(getColor(rootItem.itemType)), popup(getItemInfo(rootItem)));		   
	children = getChildren(rootItem.id);
	t = tree(root, children, std(size(50)), std(gap(20)));
	
	render(t);
}

private Figures getChildren(int parentId){
	items = calc::Cache::GetCachItemsWithParent(parentId);
	
	Figures children = [];
	for(item <- items){
		root = box(fillColor(getColor(item.itemType)), popup(getItemInfo(item)));
		
		t = tree(root, getChildren(item.id), std(size(50)), std(gap(20)));
		children += t;	
	}
	
	return children; 
} 

private str getItemInfo(calc::Cache::CacheItem item){
	str info = "";

	switch(item.itemType){
		case 0: info = "Application";
		case 1: info = "Package: <item.name>";
		case 2: info = "File: <item.name>";
		case 3: info = "Class: <item.name>";
		case 4: info = "Method: <item.name>";		
	}
	
	info +=  "\r\nSize: <item.size>";
	info +=  "\r\nComplexity: <item.complexity>";
	
	//Extra Package info
	if (item.itemType == 1){
		info += "\r\nAmount of files: <itemTypeCount(2, item.id)>";
	}
	
	//Extra File info
	if (item.itemType == 2){
		//Duplication only for file
		info +=  "\r\nDuplication: <item.duplication>";
	}
	
	//Extra class info
	if (item.itemType == 3){
		info += "\r\nAmount of methods: <itemTypeCount(4, item.id)>";
	}
		
	return info;
}

private str getColor(int itemType){	
	str color = "";

	switch(itemType){
		case 0: color = "green";
		case 1: color = "blue";
		case 2: color = "red";
		case 3: color = "darkgrey";
		case 4: color = "gold";
	}
	
	return color;
}

/**
Count the amount of item for a specific type. Start counting from a given place in the cache.
If startId is 0, then the whole cache is visited.
**/
public int itemTypeCount(int itemType, int startId){
	items = [item |  item <- calc::Cache::GetCache(), item.itemType == itemType, item.parentId == startId];
	return List::size(items); 
}

/**
source: https://stackoverflow.com/questions/20299595/hover-tooltiptext-in-rascal-figure
**/
public FProperty popup(str S){
 return mouseOver(box(text(S), fillColor("lightyellow"),
 grow(1.2),resizable(false)));
}

public void main(){
	drawTree();
}