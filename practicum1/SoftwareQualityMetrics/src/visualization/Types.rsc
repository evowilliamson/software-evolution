module visualization::Types

data ScatterData = ScatterData(
	list[DataPoint] metrics, 
	real maxXValue, 
	real minXValue, 
	real maxYValue, 
	real minYValue,
	real maxZValue, 
	real minZValue,
	str xAxisTitle,
	str yAxisTitle
	);

data Quadrant = Quadrant(int x, int y);
data DataPoint = DataPoint(str name, real x, real y, real z, str extraInfo);