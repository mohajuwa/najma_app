part of 'artist_services_bloc.dart';

abstract class ArtistServicesEvent {}

class LoadServicesEvent extends ArtistServicesEvent {}

class AddServiceEvent extends ArtistServicesEvent {
  final String  type;
  final String  nameAr;
  final String? nameEn;
  final double  price;
  final String? descriptionAr;
  AddServiceEvent({
    required this.type,
    required this.nameAr,
    this.nameEn,
    required this.price,
    this.descriptionAr,
  });
}

class UpdateServiceEvent extends ArtistServicesEvent {
  final int     id;
  final String  nameAr;
  final String? nameEn;
  final double  price;
  final String? descriptionAr;
  UpdateServiceEvent({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.price,
    this.descriptionAr,
  });
}

class ToggleServiceEvent extends ArtistServicesEvent {
  final int  id;
  final bool isActive;
  ToggleServiceEvent(this.id, this.isActive);
}

class DeleteServiceEvent extends ArtistServicesEvent {
  final int id;
  DeleteServiceEvent(this.id);
}
