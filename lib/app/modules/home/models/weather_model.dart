/// Parses the `current_weather` object from Open-Meteo response.
///
/// Example JSON:
/// ```json
/// {
///   "current_weather": {
///     "temperature": 28.5,
///     "windspeed": 12.0,
///     "weathercode": 3
///   }
/// }
/// ```
class WeatherModel {
  final double temperature;
  final double windspeed;
  final int weathercode;

  const WeatherModel({
    required this.temperature,
    required this.windspeed,
    required this.weathercode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final cw = json['current_weather'] as Map<String, dynamic>;
    return WeatherModel(
      temperature: (cw['temperature'] as num).toDouble(),
      windspeed: (cw['windspeed'] as num).toDouble(),
      weathercode: (cw['weathercode'] as num).toInt(),
    );
  }

  /// WMO weather codes → human-readable label + emoji.
  /// Reference: https://open-meteo.com/en/docs#weathervariables
  String get label {
    if (weathercode == 0) return '☀️ Clear sky';
    if (weathercode <= 3) return '⛅ Partly cloudy';
    if (weathercode <= 48) return '🌫️ Foggy';
    if (weathercode <= 67) return '🌧️ Rainy';
    if (weathercode <= 77) return '❄️ Snowy';
    if (weathercode <= 82) return '🌦️ Showers';
    if (weathercode <= 99) return '⛈️ Thunderstorm';
    return '🌡️ Unknown';
  }
}
