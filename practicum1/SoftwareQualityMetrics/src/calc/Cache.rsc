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

//Cache item types
public int APPLICATION = 0;
public int PACKAGE = 1;
public int FILE = 2;
public int CLASS = 3;
public int METHOD = 4;

private int ROOT_ITEM = 0;

private Cache cache = [];
private MethodCache methodCache = ();

/*
	Createst the method cache. Each entry in the cache will contain the methods of its own plus the methods of its children
	returns± the cache that contains per entry, the accumulated methods
*/
public MethodCache createMethodCache() {

	getMethodsInTree(cache[ROOT_ITEM]);
	return methodCache;
	
}

/*
	Recursive method that retrieves the methods of a cache item (of the general cache) and stores the accumulated methods
	in a seperate cache
	@cacheItem: the cache item for which methods are being stored in the methods cache
*/
private void getMethodsInTree(CacheItem cacheItem) {
	
	Cache methods = getMethods(cacheItem.id);
	childs = [item | item <- cache, item.parentId == cacheItem.id];
	methodCache = methodCache + (cacheItem.id: []);
	for (child <- childs) {
		if (child.itemType == METHOD) {
			// Add itself to the parent
			methodCache = methodCache + (child.parentId: methodCache[child.parentId] + child);
		}
		else {
			// First traverse the tree
			getMethodsInTree(child);
			methodCache = methodCache + (child.parentId: methodCache[child.parentId] + methodCache[child.id]);
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

public void ReadCach(){
	loc tmp = |file:///c:/temp/cach.txt|;	
	ReadCache(tmp);
}

public void ReadCache(loc file){
	calc::Logger::doLog("Read cache from file: <file>");
	cache = readTextValueFile(#Cache, file);
}

public Cache GetCache(){
	return cache; 
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

private list[CacheItem] GetCachItemsWithParent(int parentId){
	return [item | item <- cache, item.parentId == parentId];
}

private CacheItem GetCachItem(int id){
	item = [item | item <- cache, item.id == id];
	println("item: <item>");
	return item[0];	
}

public void main(){
//	drawPage();
	
	loc file = |file:///c:/temp/cach_smallsql.txt|;
	calc::Cache::ReadCache(file);
	cache = calc::Cache::GetCache();
	methodCache = createMethodCache();
	print("\nsize\n");
	print(size(methodCache[3]));

	print("\nsize\n");
	print(size(methodCache[17]));

	print("\nsize\n");
	print(size(methodCache[122]));

	print("\nsize\n");
	print(size(methodCache[1]));

}