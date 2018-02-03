module visualization::Types

data ScatterData = ScatterData(
	list[DataPoint] metrics, 
	int maxXValue, 
	int minXValue, 
	int maxYValue, 
	int minYValue,
	str xAxisTitle,
	str yAxisTitle
	);

data Quadrant = Quadrant(int x, int y);
data DataPoint = DataPoint(str name, int x, int y, str extraInfo);