import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

/// ApiService is a singleton GetxService that wraps Dio.
/// Register it once in main.dart with `Get.put(ApiService())`.
/// Any controller can then call `Get.find<ApiService>()`.
class ApiService extends GetxService {
  late final dio.Dio _dio;

  /// Base URL for Open-Meteo — free, no API key required.
  static const String _baseUrl = 'https://api.open-meteo.com/v1';

  @override
  void onInit() {
    super.onInit();
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: dio.ResponseType.json,
      ),
    );

    // Interceptor: log every request & response in debug mode
    _dio.interceptors.add(
      dio.LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Public helpers
  // ──────────────────────────────────────────────

  /// GET current weather for given lat/lon.
  /// Returns the decoded JSON [Map] or throws [DioException].
  Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get(
      '/forecast',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current_weather': true,
        'timezone': 'auto',
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Generic GET — for any future endpoint you want to add.
  Future<dio.Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get(path, queryParameters: queryParameters);
}
