import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final AuthRepositoryImpl _repo;

  AuthBloc() : super(AuthInitial()) {
    _repo = AuthRepositoryImpl(AuthDataSource());
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetAuthEvent>((_, emit) => emit(AuthInitial()));
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repo.sendOtp(event.phone);
      emit(OtpSent(event.phone));
    } on DioException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (_) {
      emit(AuthError('حدث خطأ غير متوقع'));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await _repo.verifyOtp(event.phone, event.otp, event.role);
      emit(AuthSuccess(token: auth.token, role: auth.role));
    } on DioException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (_) {
      emit(AuthError('حدث خطأ غير متوقع'));
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'] as String;
    if (e.response?.statusCode == 422) return 'رمز التحقق غير صحيح';
    if (e.response?.statusCode == 429) return 'طلبات كثيرة، حاول لاحقاً';
    if (e.type == DioExceptionType.connectionTimeout) return 'تعذّر الاتصال بالسيرفر';
    return 'حدث خطأ، حاول مرة أخرى';
  }
}
