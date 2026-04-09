import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/artists_datasource.dart';
import '../../data/repositories/artists_repository_impl.dart';
import '../../domain/entities/artist_entity.dart';

part 'artists_event.dart';
part 'artists_state.dart';

class ArtistsBloc extends Bloc<ArtistsEvent, ArtistsState> {
  late final ArtistsRepositoryImpl _repo;

  ArtistsBloc() : super(ArtistsInitial()) {
    _repo = ArtistsRepositoryImpl(ArtistsDataSource());
    on<LoadArtistsEvent>(_onLoad);
    on<LoadArtistDetailEvent>(_onDetail);
    on<RefreshArtistDetailEvent>(_onSilentRefresh);
    on<SilentRefreshArtistInListEvent>(_onRefreshInList);
  }

  Future<void> _onLoad(LoadArtistsEvent e, Emitter<ArtistsState> emit) async {
    emit(ArtistsLoading());
    try {
      final list = await _repo.getArtists(
        serviceType: e.serviceType,
        city: e.city,
      );
      emit(ArtistsLoaded(list));
    } catch (e) {
      print('NAJMA ERROR: $e'); // ← أضف هذا
      emit(ArtistsError('تعذّر تحميل الفنانين'));
    }
  }

  Future<void> _onDetail(
    LoadArtistDetailEvent e,
    Emitter<ArtistsState> emit,
  ) async {
    emit(ArtistsLoading());
    try {
      final artist = await _repo.getArtist(e.id);
      emit(ArtistDetailLoaded(artist));
    } catch (e) {
      print('ARTIST DETAIL ERROR:  $e');
      emit(ArtistsError('تعذّر تحميل بيانات الفنان'));
    }
  }

  /// تحديث صامت لصفحة التفاصيل — بدون loading
  Future<void> _onSilentRefresh(
    RefreshArtistDetailEvent e,
    Emitter<ArtistsState> emit,
  ) async {
    try {
      final artist = await _repo.getArtist(e.id);
      emit(ArtistDetailLoaded(artist));
    } catch (_) {}
  }

  /// تحديث فنان واحد في القائمة فقط — بدون إعادة تحميل كاملة
  Future<void> _onRefreshInList(
    SilentRefreshArtistInListEvent e,
    Emitter<ArtistsState> emit,
  ) async {
    // فقط إذا كانت القائمة محمّلة
    if (state is! ArtistsLoaded) return;
    try {
      final updated  = await _repo.getArtist(e.artistId);
      final oldList  = (state as ArtistsLoaded).artists;
      final newList  = oldList.map((a) {
        return a.id == e.artistId
            ? a.copyWith(
                rating:       updated.rating,
                reviewsCount: updated.reviewsCount,
              )
            : a;
      }).toList();
      emit(ArtistsLoaded(newList));
    } catch (_) {}
  }
}
