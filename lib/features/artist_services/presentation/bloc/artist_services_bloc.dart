import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/artist_services_datasource.dart';
import '../../domain/entities/artist_service_entity.dart';

part 'artist_services_event.dart';
part 'artist_services_state.dart';

class ArtistServicesBloc extends Bloc<ArtistServicesEvent, ArtistServicesState> {
  final _ds = ArtistServicesDataSource();

  ArtistServicesBloc() : super(ArtistServicesInitial()) {
    on<LoadServicesEvent>(_onLoad);
    on<AddServiceEvent>(_onAdd);
    on<UpdateServiceEvent>(_onUpdate);
    on<ToggleServiceEvent>(_onToggle);
    on<DeleteServiceEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadServicesEvent e, Emitter<ArtistServicesState> emit) async {
    emit(ArtistServicesLoading());
    try {
      final list = await _ds.getMyServices();
      emit(ArtistServicesLoaded(list));
    } catch (err) {
      emit(ArtistServicesError(_msg(err)));
    }
  }

  Future<void> _onAdd(AddServiceEvent e, Emitter<ArtistServicesState> emit) async {
    final current = _currentList();
    emit(ArtistServicesSaving(current));
    try {
      final added = await _ds.addService({
        'type':    e.type,
        'name_ar': e.nameAr,
        if (e.nameEn != null) 'name_en': e.nameEn,
        'price':   e.price,
        if (e.descriptionAr != null) 'description_ar': e.descriptionAr,
      });
      emit(ArtistServicesLoaded([added, ...current]));
      emit(const ArtistServiceActionSuccess('تمت إضافة الخدمة'));
    } catch (err) {
      emit(ArtistServicesLoaded(current));
      emit(ArtistServiceActionError(_msg(err)));
    }
  }

  Future<void> _onUpdate(UpdateServiceEvent e, Emitter<ArtistServicesState> emit) async {
    final current = _currentList();
    emit(ArtistServicesSaving(current));
    try {
      final updated = await _ds.updateService(e.id, {
        'name_ar': e.nameAr,
        if (e.nameEn != null) 'name_en': e.nameEn,
        'price':   e.price,
        if (e.descriptionAr != null) 'description_ar': e.descriptionAr,
      });
      final newList = current.map((s) => s.id == e.id ? updated : s).toList();
      emit(ArtistServicesLoaded(newList));
      emit(const ArtistServiceActionSuccess('تم تحديث الخدمة'));
    } catch (err) {
      emit(ArtistServicesLoaded(current));
      emit(ArtistServiceActionError(_msg(err)));
    }
  }

  Future<void> _onToggle(ToggleServiceEvent e, Emitter<ArtistServicesState> emit) async {
    final current = _currentList();
    // تحديث فوري في الواجهة (optimistic)
    final optimistic = current.map((s) =>
        s.id == e.id ? s.copyWith(isActive: e.isActive) : s).toList();
    emit(ArtistServicesLoaded(optimistic));
    try {
      await _ds.updateService(e.id, {'is_active': e.isActive});
    } catch (err) {
      // rollback
      emit(ArtistServicesLoaded(current));
      emit(ArtistServiceActionError(_msg(err)));
    }
  }

  Future<void> _onDelete(DeleteServiceEvent e, Emitter<ArtistServicesState> emit) async {
    final current = _currentList();
    emit(ArtistServicesLoaded(current.where((s) => s.id != e.id).toList()));
    try {
      await _ds.deleteService(e.id);
      emit(const ArtistServiceActionSuccess('تم حذف الخدمة'));
    } catch (err) {
      emit(ArtistServicesLoaded(current));
      emit(ArtistServiceActionError(_msg(err)));
    }
  }

  List<ArtistServiceEntity> _currentList() {
    final s = state;
    if (s is ArtistServicesLoaded) return s.services;
    if (s is ArtistServicesSaving) return s.services;
    return [];
  }

  String _msg(dynamic err) {
    if (err is DioException) {
      final data = err.response?.data;
      if (data is Map && data['message'] != null) return data['message'] as String;
      if (err.response?.statusCode == 422) return 'بيانات غير صحيحة';
    }
    return 'حدث خطأ، حاول مرة أخرى';
  }
}
