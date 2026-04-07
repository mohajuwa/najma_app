part of 'artists_bloc.dart';

abstract class ArtistsState {}

class ArtistsInitial extends ArtistsState {}
class ArtistsLoading extends ArtistsState {}

class ArtistsLoaded extends ArtistsState {
  final List<ArtistEntity> artists;
  ArtistsLoaded(this.artists);
}

class ArtistDetailLoaded extends ArtistsState {
  final ArtistEntity artist;
  ArtistDetailLoaded(this.artist);
}

class ArtistsError extends ArtistsState {
  final String message;
  ArtistsError(this.message);
}
