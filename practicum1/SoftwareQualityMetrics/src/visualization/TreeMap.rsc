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
import visualization::Helper;

private Cache cache = [];

private str APPLICATIONSTR = "Application";
private str PACKAGESTR = "Package";
private str CLASSSTR = "Class";
private str METHODSTR = "Method";
private int viewChoice = 0;

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
	c = combo([APPLICATIONSTR, PACKAGESTR, CLASSSTR, METHODSTR], void(str s){choice(s);});
	cb = hcat([text("Select view: "), c], vshrink(0.05)); 
	
	v = vcat([cb, t]);
	render(v);
	//render(t);				 
}

private void choice(str s){
	println("<s>");
	switch(s){
		case APPLICATIONSTR: viewChoice = calc::Cache::APPLICATION;
		case PACKAGESTR: viewChoice = calc::Cache::PACKAGE;
		case CLASSSTR: viewChoice = calc::Cache::CLASS;
		case METHODSTR: viewChoice = calc::Cache::METHOD;
	}
	
	startDrawPage();
}

private Figures getChildrenOfItemType(){
	items = [item | item <- cache, item.itemType == viewChoice];	
	applicationItem = cache[0];
	
	Figures children = [];
	for (item <- items){
		real itemArea = 1.0; //minmum value
		if (item.size > 0){
			itemArea = toReal(item.size / toReal(applicationItem.size)*100);
		}
		
		if (item.itemType == calc::Cache::CLASS){
			children += box(
		    	area(itemArea),
				fillColor(calculateColor(calculateCCRankForClass(item.id), calc::Complexity::thresholdCCUnit)), 
				visualization::Helper::popup(getItemInfo(item, cache)));
		}
		else{		
			children += box(
		    	area(itemArea),
				fillColor(calculateColor(item.complexity, calc::Complexity::thresholdCCUnit)), 
				visualization::Helper::popup(getItemInfo(item, cache)));
		}
	}
	
	return children;
}

private num calculateCCRankForClass(int classId){
	classMethods = [item | item <- cache, cache.parentId == classId];
	
	real simpleLoc = 0.0;
	real moderateLoc = 0.0;
	real highLoc = 0.0;
	real veryHighLoc = 0.0;
	
	for (classMethod <- classMethods){
		//Determine unit size of the method
		str unitSizeRank = calc::Complexity::getUnitSizeLocRank(locMethod);
		println("name: <classMethod.name>, size: <classMethod.size>, rank: <unitSizeRank>, cc: <classMethod.complexity>");
		
		//Add loc of method to relative unti size category
		switch(unitSizeRank){
			case MODERATE: moderateLoc += classMethod.size;
			case HIGH: highLoc += classMethod.size;
			case VERY_HIGH: veryHighLoc += classMethod.size;
			default: simpleLoc += classMethod.size;
		}
	}
	
	if (cache[classId-1].size > 0){
		return calc::Complexity::calculateCCRank(cache[classId-1].size, simpleLoc, moderateLoc, highLoc, veryHighLoc);
	}
	else{
		return 1;
	}	
}


/**
Calculate the color depending of the threshold.
Can be used for unit size and complexity
**/
private Color calculateColor(int currentValue, calc::Threshold::ThresholdRanksEx threshold){
	from = color("green");
	to = color("red");
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