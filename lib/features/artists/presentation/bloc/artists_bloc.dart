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
      print('ARTIST DETAIL ERROR:  $e'); // ← أضف
      emit(ArtistsError('تعذّر تحميل بيانات الفنان'));
    }
  }
}
