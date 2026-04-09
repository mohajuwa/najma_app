part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? name, lang, bioAr, bioEn, genre, iban, bankName;
  UpdateProfileEvent({
    this.name, this.lang, this.bioAr, this.bioEn,
    this.genre, this.iban, this.bankName,
  });
}

class DeleteAccountEvent extends ProfileEvent {}
