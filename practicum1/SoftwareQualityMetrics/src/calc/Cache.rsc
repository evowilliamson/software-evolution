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

private int APPLICATION = 0;
private int PACKAGE = 1;
private int FILE = 2;
private int CLASS = 3;
private int METHOD = 4;

private Cache cache = [];

/**
Get a item form the cache. If item doesn't exist then the item will be created.
@param itemType: the type of the item: PACKAGE, CLASS

return: the item form the cache or a new created item
**/
private CacheItem GetItem(int itemType, str name, int parentId, int unitSize, int complexity, int duplication){
	items = [item | item <- cache, item.itemType == itemType, item.name == name, item.parentId == parentId];
	//println("item: <item>");
	if (size(items) == 0){
		//item not found, add to cache
		newId = GetNewId();
		newItem = <newId, itemType, name, parentId, unitSize, complexity, duplication>;
		cache += newItem;
		return newItem;
	};
	
	CacheItem item = items[0];
	//println("item: <item>");
	cache[item.id-1].size += unitSize;
	cache[item.id-1].complexity += complexity;
	//println("item: <cache[item.id-1]>");
	return item;
}

/**
For now, assume that method isn't already in the cache
**/
private int AddMethodToCache(str name, int classId, int size, int complexity, int duplication){
	newId = GetNewId();
	cache += <newId, METHOD, name, classId, size, complexity, duplication>;
	return newId;
}

/**
Add a location (method) to the cache. The packages, class and file name will also be added to the cache. 
**/
public void AddLocToCache(loc l, str fileName, int unitSize, int complexity, int duplication){
	methodName = split("(", l.file)[0];	
	//println("method name: <methodName>");
	//println("filename <fileName>");
  	pathParts = split("/", l.parent.path);
  	//println("pathParts: <pathParts>");
  	s = size(pathParts)-1;  	
  	className = pathParts[s]; 
  	//println("className: <className>");
  	packages = delete(pathParts, s); //delete classname
  	//println("packages: <packages>");
  	//println("parts: <parts>");
  	//println("packages: <packages>");
  	AddItemToCache(packages, fileName, className, methodName, unitSize, complexity, duplication);
}

/**
Add a file location (e.g. class.java) to the cache.
**/
public void AddFileToCache(loc l, int unitSize, int complexity, int duplication){	
	println("file: <l.path> - <l.file> - <duplication>");
	packages = split("/", l.path);
	packages = delete(packages, 1); //delete /src part
	packages = delete(packages, size(packages)-1); //delete classname
	println("packages <packages>");
	
	
	//First package is always "". This is the application level	
	GetItem(APPLICATION, "Application", 0, unitSize, complexity, duplication);
	packages = drop(1, packages);
	
	int parentId = 1;
	for (packageName <- packages){
		package = GetItem(PACKAGE, packageName, parentId, unitSize, complexity, duplication);
		parentId = package.id;		
	};
	
	GetItem(FILE, l.file, parentId, unitSize, complexity, duplication);
}

/**
Add Item to cache. The item is a method and also the class, file and the packages are added to the cache.
**/
private void AddItemToCache(list[str] packages, str fileName, str className, str method, int unitSize, int complexity, int duplication){
	int parentId = 1;
	CacheItem package;
	
	//First package is always "". This is the application level	
	GetItem(APPLICATION, "Application", 0, unitSize, complexity, duplication);
	packages = drop(1, packages);
	
	for (packageName <- packages){
		package = GetItem(PACKAGE, packageName, parentId, unitSize, complexity, duplication);
		parentId = package.id;		
	};
		
	file = GetItem(FILE, fileName, parentId, unitSize, complexity, duplication);
	class = GetItem(CLASS, className, file.id, unitSize, complexity, duplication);
	AddMethodToCache(method, class.id, unitSize, complexity, duplication);
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

