module Types

data DuplicationAggregate = DuplicationAggregate(num totalWeight, num totalMetric, set[tuple[str unit, int weight, int metric]] metrics);
data ComplexityAggregate = ComplexityAggregate(num totalCC, num cc, num unitSize);
