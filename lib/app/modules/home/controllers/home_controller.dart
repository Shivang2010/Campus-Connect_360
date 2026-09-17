import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../models/weather_model.dart';

class HomeController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // ── Observables ──────────────────────────────────
  final Rxn<WeatherModel> weather = Rxn<WeatherModel>();
  final RxBool isLoadingWeather = false.obs;
  final RxString weatherError = ''.obs;

  // Hard-coded campus coordinates (Delhi, India).
  // In a real app you'd use geolocator package for device location.
  static const double _lat = 28.6139;
  static const double _lon = 77.2090;

  @override
  void onReady() {
    super.onReady();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      isLoadingWeather.value = true;
      weatherError.value = '';
      final data = await _api.getWeather(latitude: _lat, longitude: _lon);
      weather.value = WeatherModel.fromJson(data);
    } catch (e) {
      weatherError.value = 'Could not load weather';
      debugPrint('[HomeController] weather error: $e');
    } finally {
      isLoadingWeather.value = false;
    }
  }
}
