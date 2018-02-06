module visualization::Helper

import vis::Figure;
import vis::KeySym;

import calc::Cache;

/**
Get the color for a specific item type of the cache.
@itemType: the type of the item
@return: the color
**/
public str getColor(int itemType){	
	str color = "";

	switch(itemType){
		case 0: color = "green"; //Application
		case 1: color = "blue"; //Package
		case 2: color = "red"; //File
		case 3: color = "darkgrey"; //class
		case 4: color = "gold"; //method
	}
	
	return color;
}

/**
Create a popup
source: https://stackoverflow.com/questions/20299595/hover-tooltiptext-in-rascal-figure
@S: the text to be shown on the popup
@return: the mouseover property
**/
public FProperty popup(str S){
 return mouseOver(box(text(S), fillColor("lightyellow"),
 grow(1.2),resizable(false)));
}

/**
Get the item info about an item in the cache
@item: info about this item will be created
@cache: the cache needed for extra info
**/
public str getItemInfo(calc::Cache::CacheItem item, calc::Cache::Cache cache){
	str info = "";

	switch(item.itemType){
		case 0: info = "Application";
		case 1: info = "Package: <item.name>";
		case 2: info = "File: <item.name>";
		case 3: info = "Class: <item.name>";
		case 4: info = "Method: <item.name>";		
	}
		
	info +=  "\r\nSize: <item.size>";	
	
	//Extra application info
	if (item.itemType == 0){
		info += "\r\nAmount of packages: <calc::Cache::itemTypeCount(cache, 1, item.id)>";
	}
	
	//Extra Package info
	if (item.itemType == 1){
		info += "\r\nAmount of packages: <calc::Cache::itemTypeCount(cache, 1, item.id)>";
		info += "\r\nAmount of files: <calc::Cache::itemTypeCount(cache, 2, item.id)>";		
	}
	
	//Extra File info
	if (item.itemType == 2){
		//Duplication only for file
		info +=  "\r\nDuplication: <item.duplication> %";
	}
	
	//Extra class info
	if (item.itemType == 3){
		info += "\r\nAmount of methods: <calc::Cache::itemTypeCount(cache, 4, item.id)>";
	}
	
	//Extra method info
	if (item.itemType == 4){		
		info +=  "\r\nComplexity: <item.complexity>";		
	}
	
	info += "\r\nPath: <getPath(item, cache)>";
			
	return info;
}

/**
Get the path of an item.
e.g. if an item is a method then the path will be package/package/class/method
@item: create the path of this item
@cache: the cache with the items
@return the path of the item
**/
public str getPath(calc::Cache::CacheItem item, calc::Cache::Cache cache){
	return getPath(cache[item.parentId-1], cache, item.name);
}

private str getPath(calc::Cache::CacheItem item, calc::Cache::Cache cache, str path){
	if (item.parentId == 0){
		//application item
		return path; 
	}
	else{
		return getPath(cache[item.parentId-1], cache, "<item.name>\\<path>");
	}
}