module Types

data DuplicationAggregate = DuplicationAggregate(num totalWeight, num totalMetric, set[tuple[int weight, int metric]] metrics);
data ComplexityAggregate = ComplexityAggregate(num totalCC, num cc, num unitSize, set[tuple[int size, int complexity]] metrics);
