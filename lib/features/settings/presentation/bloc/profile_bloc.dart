import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/settings_datasource.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final _ds = SettingsDataSource();

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoad);
    on<UpdateProfileEvent>(_onUpdate);
    on<DeleteAccountEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadProfileEvent e, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final data = await _ds.getMe();
      emit(ProfileLoaded(data));
    } on Exception catch (ex) {
      emit(ProfileError(_msg(ex)));
    }
  }

  Future<void> _onUpdate(UpdateProfileEvent e, Emitter<ProfileState> emit) async {
    emit(ProfileSaving());
    try {
      await _ds.updateProfile(
        name:     e.name,
        lang:     e.lang,
        bioAr:    e.bioAr,
        bioEn:    e.bioEn,
        genre:    e.genre,
        iban:     e.iban,
        bankName: e.bankName,
      );
      // أعد تحميل البيانات بعد الحفظ
      final data = await _ds.getMe();
      emit(ProfileSaved(data));
    } on Exception catch (ex) {
      emit(ProfileError(_msg(ex)));
    }
  }

  Future<void> _onDelete(DeleteAccountEvent e, Emitter<ProfileState> emit) async {
    emit(ProfileSaving());
    try {
      await _ds.deleteAccount();
      emit(AccountDeleted());
    } on Exception catch (ex) {
      emit(ProfileError(_msg(ex)));
    }
  }

  String _msg(Exception e) {
    final s = e.toString();
    final m = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(s);
    return m?.group(1) ?? 'حدث خطأ، حاول مجدداً';
  }
}
