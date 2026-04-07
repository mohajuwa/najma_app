import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

class ApiClient {
  static Dio get dio {
    final dio = Dio(BaseOptions(
      baseUrl:        AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = LocalStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer \$token';
        }
        options.headers['Accept-Language'] = LocalStorage.getLang() ?? 'ar';
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 — clear token and redirect to OTP
        if (error.response?.statusCode == 401) {
          LocalStorage.clearToken();
          // TODO: Navigate to OTP screen
        }
        handler.next(error);
      },
    ));

    return dio;
  }
}
