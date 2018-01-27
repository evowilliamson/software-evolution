module visualization::Helper



public str getColor(int itemType){	
	str color = "";

	switch(itemType){
		case 0: color = "green";
		case 1: color = "blue";
		case 2: color = "red";
		case 3: color = "darkgrey";
		case 4: color = "gold";
	}
	
	return color;
}

