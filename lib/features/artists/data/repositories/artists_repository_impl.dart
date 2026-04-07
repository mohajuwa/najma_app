import '../../domain/entities/artist_entity.dart';
import '../../domain/repositories/artists_repository.dart';
import '../datasources/artists_datasource.dart';

class ArtistsRepositoryImpl implements ArtistsRepository {
  final ArtistsDataSource _ds;
  ArtistsRepositoryImpl(this._ds);

  @override
  Future<List<ArtistEntity>> getArtists({String? serviceType, String? city}) =>
      _ds.getArtists(serviceType: serviceType, city: city);

  @override
  Future<ArtistEntity> getArtist(int id) => _ds.getArtist(id);
}
