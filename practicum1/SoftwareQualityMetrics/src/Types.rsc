module Types

data DuplicationAggregate = DuplicationAggregate(num totalWeight, num totalMetric, list[tuple[int weight, int metric]] metrics);
data ComplexityAggregate = ComplexityAggregate(num totalCC, num cc, num unitSize, list[tuple[int size, int complexity]] metrics);
