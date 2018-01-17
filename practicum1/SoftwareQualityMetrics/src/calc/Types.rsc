module calc::Types

/**
	@author Ivo Willemsen
	Contains the user defined types that are used by the application
**/

data DuplicationAggregate = DuplicationAggregate(num totalWeight, num totalMetric, list[tuple[int weight, int metric]] metrics);
data ComplexityAggregate = ComplexityAggregate(num totalCC, num cc, num unitSize, list[tuple[int size, int complexity]] metrics);
data WindowSlider = WindowSlider(int lineIndex, int positionFirstChar, list[int] eoLines, list[int] slice);
