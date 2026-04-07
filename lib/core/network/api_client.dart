import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

/// ApiClient — Singleton حقيقي
/// كل استدعاء يستخدم نفس instance الـ Dio بدون إعادة إنشاء
class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio _dio = _buildDio();

  /// الـ dio الجاهز للاستخدام
  static Dio get dio => _instance._dio;

  // NavigatorKey لـ redirect 401 بدون context
  static void Function()? _onUnauthorized;
  static void setUnauthorizedCallback(void Function() cb) => _onUnauthorized = cb;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_LogInterceptor());

    return dio;
  }
}

// ── Auth + Language Interceptor ─────────────────────────────────
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept-Language'] = LocalStorage.getLang() ?? 'ar';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // مسح التوكن فوراً
      await LocalStorage.clearToken();
      await LocalStorage.clearAll();
      // Redirect للـ OTP
      ApiClient._onUnauthorized?.call();
    }
    handler.next(err);
  }
}

// ── Logger (dev only) ────────────────────────────────────────────
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[API] ${options.method} ${options.path}');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[API ERROR] ${err.response?.statusCode} ${err.requestOptions.path}');
      // ignore: avoid_print
      print('[API ERROR] ${err.response?.data}');
      return true;
    }());
    handler.next(err);
  }
}
