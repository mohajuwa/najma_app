part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial  extends ProfileState {}
class ProfileLoading  extends ProfileState {}
class ProfileSaving   extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> data;
  ProfileLoaded(this.data);
}

class ProfileSaved extends ProfileState {
  final Map<String, dynamic> data; // بيانات محدّثة
  ProfileSaved(this.data);
}

class AccountDeleted  extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
