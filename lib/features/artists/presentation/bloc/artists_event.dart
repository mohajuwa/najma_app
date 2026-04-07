part of 'artists_bloc.dart';

abstract class ArtistsEvent {}

class LoadArtistsEvent extends ArtistsEvent {
  final String? serviceType;
  final String? city;
  LoadArtistsEvent({this.serviceType, this.city});
}

class LoadArtistDetailEvent extends ArtistsEvent {
  final int id;
  LoadArtistDetailEvent(this.id);
}
