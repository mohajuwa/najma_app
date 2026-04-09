import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/checkout_repository_impl.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final _repo = CheckoutRepositoryImpl();

  CheckoutBloc() : super(CheckoutInitial()) {
    on<SubmitOrderEvent>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitOrderEvent e, Emitter<CheckoutState> emit) async {
    emit(CheckoutLoading());
    try {
      final order = await _repo.createOrder(
        serviceId: e.serviceId,
        fanName  : e.fanName,
        fanPhone : e.fanPhone,
        message  : e.message,
        timing   : e.timing,
      );
      final token = order['track_token'] as String? ?? '';
      emit(CheckoutSuccess(token));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String?
          ?? 'حدث خطأ في الاتصال، حاول مرة أخرى';
      emit(CheckoutError(msg));
    } catch (_) {
      emit(CheckoutError('حدث خطأ غير متوقع'));
    }
  }
}
