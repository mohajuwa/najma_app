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

/// تحديث صامت لصفحة التفاصيل — بدون loading
class RefreshArtistDetailEvent extends ArtistsEvent {
  final int id;
  RefreshArtistDetailEvent(this.id);
}

/// تحديث فنان واحد في القائمة — يُستخدم بعد العودة من صفحة التفاصيل
class SilentRefreshArtistInListEvent extends ArtistsEvent {
  final int artistId;
  SilentRefreshArtistInListEvent(this.artistId);
}
