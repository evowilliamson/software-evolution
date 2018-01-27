module visualization::scatter::Types

data ScatterData = ScatterData(
	set[tuple[int x, int y]] metrics, 
	int maxXValue, 
	int minXValue, 
	int maxYValue, 
	int minYValue,
	str xAxisTitle,
	str yAxisTitle
	);
