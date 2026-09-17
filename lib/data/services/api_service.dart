import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Response<dynamic>> get(String url) => dio.get(url);
  Future<Response<dynamic>> post(String url, {dynamic data}) =>
      dio.post(url, data: data);
  Future<Response<dynamic>> put(String url, {dynamic data}) =>
      dio.put(url, data: data);
  Future<Response<dynamic>> delete(String url) => dio.delete(url);
}
