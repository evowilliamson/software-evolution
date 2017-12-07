module Opgave4

import IO;

private list[str] getCountriesContainingLetterA(list[str] eu) {
	return 
		for (s <- eu) 
			if (/a/ := s)
				append s;
			
}

private list[str] getCountriesContainingAtleastTwoEs(list[str] eu) {
	return   
		for (s <- eu) 
			if (/e.*e/i := s)
				append s;
			
}

private list[str] getCountriesContainingExactlyTwoEs(list[str] eu) {
	return 
		for (s <- eu) 
			if (/^([^e]*e){2}[^e]*$/i := s)
				append s;
			
}

private list[str] getCountriesContainingExactlyTwoEs(list[str] eu) {
	return 
		for (s <- eu) 
			if (/^([^e]*e){2}[^e]*$/i := s)
				append s;
			
}

private list[str] getCountriesContainingNoEsAndNoNs(list[str] eu) {
	return 
		for (s <- eu) 
			if (/^[^en]*$/i := s)
				append s;
			
}

private list[str] getCountriesContainingLetterswithTwoOccurences(list[str] eu) {
	return 
		for (s <- eu) 
			if (/<x:[a-z]>.*<x>/i := s)
				append s;
			
}

private list[str] getCountriesContainingAnAWillBecomeO(list[str] eu) {
	return 
		[ begin+"o"+eind | a <- eu, /^<begin:[^a]*>a<eind:.*>$/i := a ];			
}

public void main() {

	list[str] eu = ["Belgie", "Bulgarije", "Cyprus", "Denemarken",
	"Duitsland", "Estland", "Finland", "Frankrijk", "Griekenland",
	"Hongarije", "Ierland", "Italie", "Letland", "Litouwen",
	"Luxemburg", "Malta", "Nederland", "Oostenrijk", "Polen",
	"Portugal", "Roemenie", "Slovenie", "Slowakije", "Spanje",
	"Tsjechie", "Verenigd Koninkrijk", "Zweden", "Anders"];

	println("");
	println("Opgave 4a:");
	println(getCountriesContainingLetterA(eu));
	println("");
	println("Opgave 4b:");
	println(getCountriesContainingAtleastTwoEs(eu));
	println("");
	println("Opgave 4c:");
	println(getCountriesContainingExactlyTwoEs(eu));
	println("");
	println("Opgave 4d:");
	println(getCountriesContainingNoEsAndNoNs(eu));
	println("");
	println("Opgave 4e:");
	println(getCountriesContainingLetterswithTwoOccurences(eu));
	println("");
	println("Opgave 4f:");
	println(getCountriesContainingAnAWillBecomeO(eu));
	
}