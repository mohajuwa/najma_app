import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/reviews_datasource.dart';
import 'reviews_event.dart';
import 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final _ds = ReviewsDataSource();

  ReviewsBloc() : super(const ReviewsInitial()) {
    on<LoadReviewsEvent>(_onLoad);
    on<CheckReviewStatusEvent>(_onCheckStatus);
    on<SubmitReviewEvent>(_onSubmit);
  }

  Future<void> _onLoad(LoadReviewsEvent e, Emitter emit) async {
    emit(const ReviewsLoading());
    try {
      final reviews = await _ds.getReviews(e.artistId);
      emit(ReviewsLoaded(reviews));
    } catch (_) {
      emit(ReviewsLoaded(const []));
    }
  }

  /// جلب حالة التقييم: هل يمكن التقييم / التعديل؟
  Future<void> _onCheckStatus(CheckReviewStatusEvent e, Emitter emit) async {
    try {
      final status = await _ds.getReviewStatus(e.artistId);
      emit(ReviewStatusLoaded(status));
    } catch (_) {
      // فشل صامت — الـ UI سيخفي الزر بشكل افتراضي
    }
  }

  Future<void> _onSubmit(SubmitReviewEvent e, Emitter emit) async {
    emit(const ReviewsSubmitting());
    try {
      await _ds.addReview(e.artistId, e.rating, e.comment);
      emit(const ReviewSubmitted('تم إرسال تقييمك بنجاح ✨'));
      // أعد تحميل القائمة + إعادة فحص الـ status
      add(LoadReviewsEvent(e.artistId));
      add(CheckReviewStatusEvent(e.artistId));
    } catch (err) {
      final msg = _parseError(err);
      emit(ReviewSubmitError(msg));
    }
  }

  String _parseError(Object err) {
    if (err is DioException) {
      final data = err.response?.data;
      if (data is Map) {
        final msg = data['message'] as String?;
        if (msg != null) return msg;
      }
      final code = err.response?.statusCode;
      if (code == 422) return 'لا يمكنك التقييم — تحقق من شروط التقييم';
      if (code == 403) return 'غير مصرح لك بالتقييم';
    }
    return 'حدث خطأ، حاول مرة أخرى';
  }
}
