import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/onboard_datasource.dart';

part 'onboard_event.dart';
part 'onboard_state.dart';

class OnboardBloc extends Bloc<OnboardEvent, OnboardState> {
  final _ds = OnboardDataSource();

  // قائمة الخدمات المؤقتة بعد تسجيل الملف الشخصي
  final List<Map<String, dynamic>> _pendingServices = [];

  OnboardBloc() : super(OnboardInitial()) {
    on<SubmitProfileEvent>(_onSubmitProfile);
    on<AddServiceEvent>(_onAddService);
    on<RemoveLocalServiceEvent>(_onRemoveLocal);
    on<FinishOnboardEvent>(_onFinish);
  }

  // ── خطوة 1: إرسال الملف الشخصي ──────────────────────────────────
  Future<void> _onSubmitProfile(
    SubmitProfileEvent event,
    Emitter<OnboardState> emit,
  ) async {
    emit(OnboardLoading());
    try {
      await _ds.registerArtist(
        bioAr:    event.bioAr,
        bioEn:    event.bioEn,
        genre:    event.genre,
        iban:     event.iban,
        bankName: event.bankName,
      );
      _pendingServices.clear();
      emit(ProfileSubmitted(localServices: []));
    } on Exception catch (e) {
      emit(OnboardError(_parseError(e)));
    }
  }

  // ── إضافة خدمة لقائمة مؤقتة ──────────────────────────────────────
  Future<void> _onAddService(
    AddServiceEvent event,
    Emitter<OnboardState> emit,
  ) async {
    _pendingServices.add({
      'type':           event.type,
      'name_ar':        event.nameAr,
      'price':          event.price,
      'description_ar': event.descriptionAr,
    });
    emit(ServiceAdded(List.from(_pendingServices)));
  }

  // ── حذف خدمة من القائمة المحلية ──────────────────────────────────
  void _onRemoveLocal(
    RemoveLocalServiceEvent event,
    Emitter<OnboardState> emit,
  ) {
    if (event.index >= 0 && event.index < _pendingServices.length) {
      _pendingServices.removeAt(event.index);
    }
    emit(ServiceAdded(List.from(_pendingServices)));
  }

  // ── خطوة 2: إرسال جميع الخدمات ──────────────────────────────────
  Future<void> _onFinish(
    FinishOnboardEvent event,
    Emitter<OnboardState> emit,
  ) async {
    if (_pendingServices.isEmpty) {
      emit(OnboardDone());
      return;
    }

    for (int i = 0; i < _pendingServices.length; i++) {
      emit(ServicesSubmitting(current: i + 1, total: _pendingServices.length));
      try {
        final s = _pendingServices[i];
        await _ds.addService(
          type:          s['type'] as String,
          nameAr:        s['name_ar'] as String,
          price:         (s['price'] as num).toDouble(),
          descriptionAr: s['description_ar'] as String?,
        );
      } on Exception catch (e) {
        emit(OnboardError('خطأ في إضافة الخدمة ${i + 1}: ${_parseError(e)}'));
        return;
      }
    }

    emit(OnboardDone());
  }

  String _parseError(Exception e) {
    final msg = e.toString();
    // استخرج رسالة الـ API إن وُجدت
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(msg);
    return match?.group(1) ?? 'حدث خطأ، حاول مجدداً';
  }
}
