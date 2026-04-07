import '../entities/artist_entity.dart';

abstract class ArtistsRepository {
  Future<List<ArtistEntity>> getArtists({String? serviceType, String? city});
  Future<ArtistEntity>       getArtist(int id);
}
