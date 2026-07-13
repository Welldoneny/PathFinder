class PredictResult {
  final double water;
  final double food;
  final double time;

  PredictResult({required this.water, required this.food, required this.time});

  factory PredictResult.fromJson(Map<String, dynamic> json) => PredictResult(
    water: (json['water'] as num).toDouble(),
    food: (json['food'] as num).toDouble(),
    time: (json['time'] as num).toDouble(),
  );
}