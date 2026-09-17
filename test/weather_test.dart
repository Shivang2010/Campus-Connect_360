import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_360/app/modules/home/models/weather_model.dart';

void main() {
  group('WeatherModel Unit Tests', () {
    test('fromJson correctly parses Open-Meteo current_weather payload', () {
      final json = {
        'latitude': 28.61,
        'longitude': 77.21,
        'current_weather': {
          'temperature': 29.4,
          'windspeed': 11.2,
          'weathercode': 1,
          'is_day': 1,
          'time': '2026-09-17T06:00'
        }
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temperature, 29.4);
      expect(model.windspeed, 11.2);
      expect(model.weathercode, 1);
      expect(model.label, contains('Partly cloudy'));
    });

    test('label helper maps different WMO codes properly', () {
      final clear = WeatherModel(temperature: 30, windspeed: 5, weathercode: 0);
      expect(clear.label, contains('Clear sky'));

      final rain = WeatherModel(temperature: 20, windspeed: 15, weathercode: 61);
      expect(rain.label, contains('Rainy'));

      final storm = WeatherModel(temperature: 18, windspeed: 25, weathercode: 95);
      expect(storm.label, contains('Thunderstorm'));
    });
  });
}
