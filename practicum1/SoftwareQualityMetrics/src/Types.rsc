module Types

data MetricAggregate = MetricAggregate(num totalWeight, num totalMetric, set[tuple[str unit, int weight, int metric]] metrics);
