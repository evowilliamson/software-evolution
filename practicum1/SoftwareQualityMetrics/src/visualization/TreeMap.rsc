module visualization::TreeMap

import vis::Figure;
import vis::Render;
import IO;
import List;
import vis::KeySym;
import util::Math; 

import calc::Cache;
import calc::Complexity;
import calc::Threshold;
import calc::Duplication;
import visualization::Helper;

private Cache cache = [];

//Constants
private str APPLICATIONSTR = "Application";
private str PACKAGESTR = "Package";
private str CLASSSTR = "Class";
private str METHODSTR = "Method";
private str FILESTR = "File";
private int viewChoice = 0;

private str COLOR_START = "green";
private str COLOR_END = "red";

/**
Main method to start drawing the treemap.
**/
public void main(){
	//loc file = |file:///c:/temp/cach_test.txt|;	
	loc file = |file:///c:/temp/cach_smallsql.txt|;
	calc::Cache::ReadCaches();
	cache = calc::Cache::GetCache();
		
	startDrawPage();
}

/**
Draw a tree map, the size of the boxes are the size of the items (package, file) and the color represents the complexity
The item type File will not be drawn. We assume that a file contains at most one class. 
**/
private void startDrawPage(){
	application = cache[0];
	
	Figures children = [];
	if (viewChoice == calc::Cache::APPLICATION){
		children = getChildrenAllItemTypes(application.id);
	}
	else{
		children = getChildrenOfItemType();		
	}
	
	t = treemap(children);
	c = combo([APPLICATIONSTR, PACKAGESTR, FILESTR, CLASSSTR, METHODSTR], void(str s){choice(s);});
	cb = hcat([text("Select view: "), c], vshrink(0.05)); 
	
	v = vcat([cb, t]);
	render(v);			 
}

/**
Callback method for the "Select view" combo
The treemap will be redrawn
**/
private void choice(str s){
	println("<s>");
	switch(s){
		case APPLICATIONSTR: viewChoice = calc::Cache::APPLICATION;
		case PACKAGESTR: viewChoice = calc::Cache::PACKAGE;
		case CLASSSTR: viewChoice = calc::Cache::CLASS;
		case FILESTR: viewChoice = calc::Cache::FILE;
		case METHODSTR: viewChoice = calc::Cache::METHOD;
	}
	
	startDrawPage();
}

/**
Get figures for all the children of a item type (e.g. class, package). Depends on the choice in the combo.
@return: a list with figures 
**/
private Figures getChildrenOfItemType(){
	items = [item | item <- cache, item.itemType == viewChoice];	
	applicationItem = cache[0];
	
	Figures children = [];
	for (item <- items){
		real itemArea = 0.1; //minmum value
		if (item.size > 0){
			itemArea = toReal((item.size / toReal(applicationItem.size))*100);
		}
		
		if (item.itemType == calc::Cache::PACKAGE){					 
			children += box(
		    	area(itemArea),
				fillColor(interpolateColor(color(COLOR_START), color(COLOR_END), (item.size / toReal(applicationItem.size)))), 
				visualization::Helper::popup(getItemInfo(item, cache)));
		}
		if (item.itemType == calc::Cache::FILE){					 
			children += box(
		    	area(itemArea),
				fillColor(calculateDuplicationColor(item.duplication)), 
				visualization::Helper::popup(getItemInfo(item, cache)));
		}
		else if (item.itemType == calc::Cache::CLASS){
			children += box(
		    	area(itemArea),
				fillColor(calculateCCColorForClass(item.id)), 
				visualization::Helper::popup(getItemInfo(item, cache)));
		}
		else if (item.itemType == calc::Cache::METHOD){		
			children += box(
		    	area(itemArea),
				fillColor(calculateColor(item.complexity, calc::Complexity::thresholdCCUnit)), 
				visualization::Helper::popup(getItemInfo(item, cache)));
		}
	}
	
	return children;
}

/**
Calculate the color for the aggregrated cc for a class
@classId: the id of the class in the cache
@return the color representing the aggregrated cc
**/
private Color calculateCCColorForClass(int classId){
	classMethods = [item | item <- cache, item.parentId == classId];
	
	//LOC for all methods of a class
	real simpleLoc = 0.0;
	real moderateLoc = 0.0;
	real highLoc = 0.0;
	real veryHighLoc = 0.0;
	
	for (classMethod <- classMethods){
		//Determine unit size of the method
		str unitSizeRank = calc::Complexity::getUnitSizeLocRank(classMethod.size);
		println("name: <classMethod.name>, size: <classMethod.size>, rank: <unitSizeRank>, cc: <classMethod.complexity>");
		
		//Add loc of method to relative unti size category
		switch(unitSizeRank){
			case "simple": simpleLoc += classMethod.size;
			case "moderate": moderateLoc += classMethod.size;
			case "high": highLoc += classMethod.size;
			case "very high": veryHighLoc += classMethod.size;			
		}
	}
	
	from = color(COLOR_START);
	to = color(COLOR_END);
	percentage = 0.0;
	if (cache[classId-1].size > 0){
		rank = calc::Complexity::calculateCCRank(cache[classId-1].size, simpleLoc, moderateLoc, highLoc, veryHighLoc);
		println("rank <rank>");
		switch(rank){
			case 2: percentage = 0.0;
			case 3: percentage = 0.25;
			case 4: percentage = 0.5;
			case 5: percentage = 0.75;
			case 6: percentage = 1.0; 
		}
		return interpolateColor(from, to, percentage);
	}
	else{
		return from;
	}	
}

/**
Calculatie the color for the duplication
**/
private Color calculateDuplicationColor(int duplication){
	str rank = calc::Threshold::getRank(duplication, calc::Duplication::duplicationRanks);
	
	from = color(COLOR_START);
	to = color(COLOR_END);

	percentage = 0.0;
	switch(rank){
		case "++": percentage = 0.0;
		case "+": percentage = 0.25;
		case "o": percentage = 0.50;
		case "-": percentage = 0.75;
		case "--": percentage = 1.0;
	}
	
	return interpolateColor(from, to, percentage);
}

/**
Calculate the color depending of the threshold.
Can be used for unit size and complexity
**/
private Color calculateColor(int currentValue, calc::Threshold::ThresholdRanksEx threshold){
	from = color(COLOR_START);
	to = color(COLOR_END);
	rank = getRankNum(currentValue, threshold);
	
	//println("rank <rank>");
	percentage = 0.0;
	switch(rank){
		case 5: percentage = 0.0;
		case 4: percentage = 0.33;
		case 3: percentage = 0.67;
		case 2: percentage = 1.0;		
	}
	
	return interpolateColor(from, to, percentage);
}

/**
Get the children of them item with the given parent id
**/
private Figures getChildrenAllItemTypes(int parentId){
	items = calc::Cache::GetItemsWithParent(cache, parentId);
	
	currentItem = cache[parentId-1];
	applicationItem = cache[0];

	Figures children = [];
	for(item <- items){		
		c = getChildrenAllItemTypes(item.id);
		t = treemap(c, shrink(0.95));		
		
		real itemArea = 1.0; //minmum value
		if (currentItem.size > 0){
			itemArea = toReal(item.size / toReal(applicationItem.size)*100);
		}
		//println("<item.size> - <currentItem.size> - <itemArea>");				
		if (item.itemType != calc::Cache::FILE){
			children += box(t,
			    area(itemArea),
				fillColor(visualization::Helper::getColor(item.itemType)), 
				visualization::Helper::popup(getItemInfo(item, cache)));
		}
		else{
			children += t;
		}			
	}
	
	return children; 
}