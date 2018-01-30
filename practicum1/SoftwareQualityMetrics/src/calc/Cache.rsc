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
alias MethodCache = map[int, Cache]; 

alias ExtendedCacheItem = tuple[CacheItem cacheItem, str fullPackage];
alias ExtendedCache = list[ExtendedCacheItem];
alias ExtendedCacheMap = map[int, ExtendedCache];

//Cache item types
public int APPLICATION = 0;
public int PACKAGE = 1;
public int FILE = 2;
public int CLASS = 3;
public int METHOD = 4;

private int ROOT_ITEM = 0;
private int ID_ROOT_ELEMENT = 1;

private	loc MAIN_CACHE_LOCATION = |file:///c:/temp/cach.txt|;
private	loc EXTENDED_CACHE_LOCATION = |file:///c:/temp/cach_extended.txt|;

private Cache cache = [];
private MethodCache methodCache = ();
private ExtendedCacheMap extendedCacheMap = ();

/*
	Createst the method cache. Each entry in the cache will contain the methods of its own plus the methods of its children
	returns± the cache that contains per entry, the accumulated methods
*/
public ExtendedCacheMap createMethodCache() {

	getMethodsInTree(cache[ROOT_ITEM]);
	return extendedCacheMap;
	
}

private void printlnObject(value theValue, str tag_) {
	print(tag_); print(theValue); print("\n");
}

/*
	Recursive method that retrieves the methods of a cache item (of the general cache) and stores the accumulated methods
	in a seperate cache
	@cacheItem: the cache item for which methods are being stored in the methods cache
*/
private void getMethodsInTree(CacheItem cacheItem) {
	
	Cache methods = getMethods(cacheItem.id);
	childs = [item | item <- cache, item.parentId == cacheItem.id];
	extendedCacheMap = extendedCacheMap + (cacheItem.id: []);
	for (child <- childs) {
		if (child.itemType == METHOD) {
			// Add itself to the parent
			printlnObject(getFullyQualifiedName(child.id), "Full");
			extendedCacheMap = extendedCacheMap + 
				(child.parentId: extendedCacheMap[child.parentId] + <child, replaceFirst(getFullyQualifiedName(child.parentId),".", "")>);
		}
		else {
			// First traverse the tree
			getMethodsInTree(child);
			extendedCacheMap = extendedCacheMap + (child.parentId: extendedCacheMap[child.parentId] + extendedCacheMap[child.id]);
		}
	}
	
}

private str getFullyQualifiedName(int id) {

	CacheItem cacheItem = getCacheItem(id);
	if (cacheItem.id != ID_ROOT_ELEMENT) {
		return getFullyQualifiedName(cacheItem.parentId) + "." + replaceAll(cacheItem.name, ".java", "");
	}
	else {
		return "";
	}

}

private CacheItem getCacheItem(int id) {

	for (cacheItem <- cache) {
		if (cacheItem.id == id) {
			return cacheItem;
		}
	}

}

/*
	Get the methods that belong to the class that is represented by the id that is passed to the method
	@id: id of the class
	returns: the list of cacheItems (method)
*/
private Cache getMethods(int id) {

	return [item | item <- cache, item.parentId == id && item.itemType == METHOD];

}

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
	//println("file: <l.path> - <l.file> - <duplication>");
	packages = split("/", l.path);
	packages = delete(packages, 1); //delete /src part
	packages = delete(packages, size(packages)-1); //delete classname
	//println("packages <packages>");
	
	
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

public void PrintCache(){
	println("cache: <cache>");
}

public void ReadCaches(){

	calc::Logger::doLog("Read main cache from file: <MAIN_CACHE_LOCATION>");
	cache = readTextValueFile(#Cache, MAIN_CACHE_LOCATION);
	calc::Logger::doLog("Read main cache from file: <EXTENDED_CACHE_LOCATION>");
	extendedCacheMap = readTextValueFile(#ExtendedCacheMap, EXTENDED_CACHE_LOCATION);
}

public Cache GetCache(){
	return cache; 
}

public ExtendedCacheMap GetExtendedCacheMap(){
	return extendedCacheMap; 
}

/**
Count the amount of item for a specific type. Start counting from a given place in the cache.
If startId is 0, then the whole cache is visited.
**/
public int itemTypeCount(calc::Cache::Cache cache, int itemType, int startId){
	items = [item |  item <- cache, item.itemType == itemType, item.parentId == startId];
	return List::size(items); 
}

public list[CacheItem] GetItemsWithParent(Cache cache, int parentId){
	return [item | item <- cache, item.parentId == parentId];
}

/**
Save both caches to a file
**/
public void SaveCache(){	
	
	// Write the main cachce
	calc::Logger::doLog("Write main cache to file: <MAIN_CACHE_LOCATION>");
	writeTextValueFile(MAIN_CACHE_LOCATION, cache);
	// Write the extended cachce
	calc::Logger::doLog("Write extended cache to file: <EXTENDED_CACHE_LOCATION>");
	writeTextValueFile(EXTENDED_CACHE_LOCATION, extendedCacheMap);

}

public void ClearCache(){
	cache = [];
}

private int GetNewId(){
	return size(cache) + 1;
}

private list[CacheItem] GetCachItemsWithParent(int parentId){
	return [item | item <- cache, item.parentId == parentId];
}

private CacheItem GetCachItem(int id){
	item = [item | item <- cache, item.id == id];
	println("item: <item>");
	return item[0];	
}

public void main(){
	
	calc::Cache::ReadCaches();
	cache = calc::Cache::GetCache();
	for (cacheItem <- cache) {
		print(cacheItem); print("\n");
	}
	print("\n");
	extendedCacheMap = calc::Cache::GetExtendedCacheMap();
	for (id <- extendedCacheMap) {
		print(id); print(": "); printlnObject(extendedCacheMap[id], "element");
	}

	print(getFullyQualifiedName(19));	
	print(size(extendedCacheMap[1]));

}