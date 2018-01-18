module calc::Cache

import String;
import List;
import IO;
import ValueIO;
import calc::Logger;

/**
id: id of the package, class or method in the Cache
itemType: type of the cache item: 1: package, 2: class, 3: method
name: name of package, class or method
parentId: id of parent of the package, class or method. If parent is not available then then value will be 0.  
size: unit size of package, class or method
complexity: cyclomatic complexity of package, class or method
duplication: the duplication of the package, class or method
**/
alias CacheItem = tuple[int id, int itemType, str name, int parentId, int size, int complexity, int duplication];
alias Cache = list[CacheItem];

private int PACKAGE = 1;
private int CLASS = 2;
private int METHOD = 3;

private Cache cache = [];


/**
Get the id of a package. If not exist, then the package is added to the cached

return: id of the package in the cache 
**/
public int GetPackageId(str name, int parentId){
	package = [item | item <- cache, item.itemType == PACKAGE, item.name == name, item.parentId == parentId];
	//println("package: <package>");
	if (size(package) == 0){
		//package not found, add to cache
		newId = GetNewId();
		cache += <newId, PACKAGE, name, parentId, 0, 0, 0>;
		return newId;
	};
	
	return package[0].id;
}

/**
Get the id of a class. If not exist, then the class is added to the cached

return: id of the package in the cache
**/
public CacheItem GetClass(str name, int parentId, int unitSize, int complexity){
	classes = [item | item <- cache, item.itemType == CLASS, item.name == name, item.parentId == parentId];
	
	if (size(classes) == 0){
		//class not found, add to cache
		newId = GetNewId();
		newClass = <newId, CLASS, name, parentId, unitSize, complexity, 0>;
		cache += newClass;
		return newClass;
	};
	
	CacheItem class = classes[0];
	println("class: <class>");
	cache[class.id-1].size += unitSize;
	cache[class.id-1].complexity += complexity;
		println("class: <cache[class.id-1]>");
	return class;
}

/**
For now, assume that method isn't already in the cache
**/
public int AddMethodToCache(str name, int classId, int size, int complexity){
	newId = GetNewId();
	cache += <newId, METHOD, name, classId, size, complexity, 0>;
	return newId;
}


public void AddLocToCache(loc l, int unitSize, int complexity){
	methodName = split("(", l.file)[0];	
	//println("method name: <methodName>");
  	pathParts = split("/", l.parent.path);
  	//println("pathParts: <pathParts>");
  	s = size(pathParts)-1;  	
  	className = pathParts[s]; 
  	//println("className: <className>");
  	packages = delete(pathParts, s); //delete classname
  	//println("packages: <packages>");
  	//println("parts: <parts>");
  	//println("packages: <packages>");
  	AddItemToCache(packages, className, methodName, unitSize, complexity);
}

/**
Add Item to cache
**/
public void AddItemToCache(list[str] packages, str className, str method, int size, int complexity){
	int parentId = 0;
	for (package <- packages){
		parentId = GetPackageId(package, parentId);			
	};
	
	class = GetClass(className, parentId, size, complexity);
	AddMethodToCache(method, class.id, size, complexity);
}

public void printCache(){
	println("cache: <cache>");
}

/**
Save the cache to file
**/
public void SaveCache(){	
	loc tmp = |file:///c:/temp/cach.txt|;
	calc::Logger::doLog("Write cache to file: <tmp>");
	
	writeTextValueFile(tmp, cache);
}

public void ClearCache(){
	cache = [];
}

private int GetNewId(){
	return size(cache) + 1;
}

private CacheItem GetCachItem(int id){
	item = [item | item <- cache, item.id == id];
	println("item: <item>");
	return item[0];	
}

