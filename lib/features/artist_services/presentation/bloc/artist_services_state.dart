part of 'artist_services_bloc.dart';

abstract class ArtistServicesState {
  const ArtistServicesState();
}

class ArtistServicesInitial extends ArtistServicesState {}

class ArtistServicesLoading extends ArtistServicesState {}

class ArtistServicesLoaded extends ArtistServicesState {
  final List<ArtistServiceEntity> services;
  const ArtistServicesLoaded(this.services);
}

class ArtistServicesSaving extends ArtistServicesState {
  final List<ArtistServiceEntity> services; // القائمة الحالية أثناء الحفظ
  const ArtistServicesSaving(this.services);
}

class ArtistServicesError extends ArtistServicesState {
  final String message;
  const ArtistServicesError(this.message);
}

/// نجاح عملية (إضافة/تعديل/حذف) — يظهر snackbar ثم يختفي
class ArtistServiceActionSuccess extends ArtistServicesState {
  final String message;
  const ArtistServiceActionSuccess(this.message);
}

class ArtistServiceActionError extends ArtistServicesState {
  final String message;
  const ArtistServiceActionError(this.message);
}
