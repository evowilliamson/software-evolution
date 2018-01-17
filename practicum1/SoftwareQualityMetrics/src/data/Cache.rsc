module Cache

import String;
import List;
import IO;
import ValueIO;

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
	println("package: <package>");
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
public int GetClassId(str name, int parentId){
	class = [item | item <- cache, item.itemType == CLASS, item.name == name, item.parentId == parentId];
	println("class: <class>");
	
	if (size(class) == 0){
		//class not found, add to cache
		newId = GetNewId();
		cache += <newId, CLASS, name, parentId, 0, 0, 0>;
		return newId;
	};
	
	return class[0].id;
}

/**
For now, assume that method isn;t in cache
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
public void AddItemToCache(list[str] packages, str class, str method, int size, int complexity){
	int parentId = 0;
	for (package <- packages){
		parentId = GetPackageId(package, parentId);			
	};
	
	classId = GetClassId(class, parentId);
	AddMethodToCache(method, classId, size, complexity);
}

public void printCache(){
	println("cache: <cache>");
}

/**
Save the cache to file
**/
public void SaveCache(){
	loc tmp = |file:///c:/temp/cach.txt|;
	
	writeTextValueFile(tmp, cache);
}

private int GetNewId(){
	return size(cache) + 1;
}
