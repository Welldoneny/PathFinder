class WeatherModel {
  final double temp;
  final int humidity;

  WeatherModel({required this.temp, required this.humidity});

  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
    temp: (json['temp'] as num).toDouble(),
    humidity: (json['humidity'] as num).toInt(),
  );
}
