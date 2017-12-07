// Uitwerking van de Rascal oefeningen (inwerkopdracht) 
// Open Universiteit, november 2017
module Uitwerking

import IO;
import List;
import Map;
import Relation;
import Set;
import analysis::graphs::Graph;
import util::Resources;
import lang::java::jdt::m3::Core;
import analysis::m3::Core;

// --------------------------------------------------------------------------
// Opgave 4: Reguliere expressies

list[str] eu = ["Belgie", "Bulgarije", "Cyprus", "Denemarken", 
   "Duitsland", "Estland", "Finland", "Frankrijk", "Griekenland", 
   "Hongarije", "Ierland", "Italie", "Letland", "Litouwen", 
   "Luxemburg", "Malta", "Nederland", "Oostenrijk", "Polen", 
   "Portugal", "Roemenie", "Slovenie", "Slowakije", "Spanje", 
   "Tsjechie", "Verenigd Koninkrijk", "Zweden"];

public void opgave4() {
   // bevat de letter 's'
   println("(4a)");
   println([ a | a <- eu, /s/i := a ]);
   // bevat (tenminste) twee 'e''s
   println("(4b)");
   println([ a | a <- eu, /e.*e/i := a ]);
   // bevat precies twee 'e's
   println("(4c)");
   println([ a | a <- eu, /^([^e]*e){2}[^e]*$/i := a ]);
   // bevat geen 'n' en geen 'e'
   println("(4d)");
   println([ a | a <- eu, /^[^en]*$/i := a ]);
   // bevat een letter met tenminste twee voorkomens
   println("(4e)");
   println([ a | a <- eu, /<x:[a-z]>.*<x>/i := a ]);
   // bevat een 'a' (eerste wordt een o)
   println("(4f)");
   println([ begin+"o"+eind | a <- eu, /^<begin:[^a]*>a<eind:.*>$/i := a ]);
}

// --------------------------------------------------------------------------
// Opgave 5: Functies met getallen

public rel[int, int] delers(int maxnum) {
   return { <a, b> | a <- [1..maxnum], b <- [1..a+1], a%b==0 };
}

public void opgave5() {
   rel[int, int] d = delers(100);
   // relatie met delers
   println("(5a)");
   println(d);
   // meeste delers
   println("(5b)");
   map[int, int] m = (a:size(d[a]) | a <- domain(d));
   int maxdiv = max(range(m)); 
   println({ a | a <- domain(d), m[a] == maxdiv });
   // priemgetallen (oplopend)
   println("(5c)");
   println(sort([ a | a <- domain(m), m[a] == 2 ]));
}

// --------------------------------------------------------------------------
// Opgave 6: Relaties

public Graph[str] gebruikt = {<"A", "B">, <"A", "D">, 
   <"B", "D">, <"B", "E">, <"C", "B">, <"C", "E">, 
   <"C", "F">, <"E", "D">, <"E", "F">};

public void opgave6() {
   componenten = carrier(gebruikt);
   // aantal componenten
   println("(6a)");
   println(size(componenten));
   // aantal afhankelijkheden
   println("(6b)");
   println(size(gebruikt));
   // ongebruikte componenten
   println("(6c)");
   println(top(gebruikt));
   // (in)direct nodig voor A 
   println("(6d)");
   println((gebruikt+)["A"]);
   // in(direct) niet gebruikt door C
   println("(6e)");
   println(componenten - (gebruikt*)["C"]);
   // aantal keren (direct) gebruikt 
   println("(6f)");
   println(( a:size(invert(gebruikt)[a]) | a <- componenten ));
}

// --------------------------------------------------------------------------
// Opgave 7: Eclipse project

public set[loc] javaBestanden(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}

public bool aflopend(tuple[&a, num] x, tuple[&a, num] y) {
   return x[1] > y[1];
} 

public void opgave7() {
   set[loc] bestanden = javaBestanden(|project://JabberPoint/|);
   // aantal Java-bestanden
   println("(7a)");
   println(size(bestanden));
   // aantal regels per Java-bestand
   println("(7b)");
   map[loc, int] regels = ( a:size(readFileLines(a)) | a <- bestanden );
   for (<loc a, int b> <- sort(toList(regels), aflopend))
      println("<a.file>: <b> regels");
   // aantal methoden per klasse (gesorteerd)
   println("(7c)");
   M3 model = createM3FromEclipseProject(|project://JabberPoint/|);
   methoden =  { <x,y> | <x,y> <- model.containment
                       , x.scheme=="java+class"
                       , y.scheme=="java+method" || y.scheme=="java+constructor" 
                       };
   telMethoden = { <a, size(methoden[a])> | a <- domain(methoden) };
   for (<a,n> <- sort(telMethoden, aflopend))
      println("<a>: <n> methoden");
   // klasse met meeste subklassen
   println("(7d)");
   subklassen = invert(model.extends);
   telKinderen = { <a, size((subklassen+)[a])> | a <- domain(subklassen) };
   for (<a, n> <- sort(telKinderen, aflopend))
      println("<a>: <n> subklassen");
}
