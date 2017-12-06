module Opgave6

import IO;
import List;
import Map;
import Relation;
import Set;
import analysis::graphs::Graph;
import util::Resources;
import lang::java::jdt::m3::Core;
import analysis::m3::Core;

private Graph[str] graph = {<"A", "B">, <"A", "D">, <"B", "E">, <"B", "D">, <"C", "B">, 
					<"C", "E">, <"C", "F">, <"E", "D">, <"E", "F">};

private int getComponountCount(Graph graph) {
	return size(getComponents(graph));
}

private set[str] getComponents(Graph graph) {
	return carrier(graph);
}

private int getDependencyCount(Graph graph) {
	return size(graph);
}

private set[str] getEntryPoints(Graph graph) {
	 return top(graph);
}

private set[str] getDependentComponents(Graph graph, str component) {
	return (graph+)["A"];
}

private set[str] getNotDependentComponents(Graph graph, str component) {
	return getComponents(graph) - getDependentComponents(graph, component);
}

private map[str, int] getUsageCount(Graph graph) {
	 return (a:size(invert(graph)[a]) | a <- getComponents(graph));
}

public void main() {

	println("");
	println("Opgave 6a:");
	print("Number of components: ");
	println(getComponountCount(graph));
	println("");
	println("Opgave 6b:");
	print("Number of dependencies: ");
	println(getDependencyCount(graph));
	println("");
	println("Opgave 6c:");
	print("Entrypoints of graph: ");
	println(getEntryPoints(graph));

	println("");
	println("Opgave 6d:");
	print("Dependent components of component A: ");
	println(getDependentComponents(graph, "A"));
	println("");
	println("Opgave 6e:");
	print("Non-dependent components of component C: ");
	println(getNotDependentComponents(graph, "C"));
	println("");
	println("Opgave 6f:");
	print("Usage count: ");
	println(getUsageCount(graph));
		
}
