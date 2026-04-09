import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_button.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/l10n/app_strings.dart';
import '../bloc/profile_bloc.dart';

const _genres = [
  'طرب عربي', 'شعبي', 'خليجي', 'كلاسيكي', 'جاز', 'روك',
  'هيب هوب', 'إلكترونيك', 'فلكلور', 'ديني', 'أطفال', 'أخرى',
];

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(LoadProfileEvent()),
      child: const _EditProfileBody(),
    );
  }
}

class _EditProfileBody extends StatefulWidget {
  const _EditProfileBody();
  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  final _nameCtrl  = TextEditingController();
  final _bioArCtrl = TextEditingController();
  final _bioEnCtrl = TextEditingController();
  final _ibanCtrl  = TextEditingController();
  final _bankCtrl  = TextEditingController();
  String? _genre;
  bool _isArtist = false;
  bool _loaded   = false;
  String _phone  = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioArCtrl.dispose();
    _bioEnCtrl.dispose();
    _ibanCtrl.dispose();
    _bankCtrl.dispose();
    super.dispose();
  }

  void _populate(Map<String, dynamic> data) {
    if (_loaded) return;
    _loaded = true;
    _nameCtrl.text = data['name'] as String? ?? '';
    _phone = data['phone'] as String? ?? '';
    _isArtist = data['artist'] != null;
    if (_isArtist) {
      final a = data['artist'] as Map<String, dynamic>;
      _bioArCtrl.text = a['bio_ar']    as String? ?? '';
      _bioEnCtrl.text = a['bio_en']    as String? ?? '';
      _ibanCtrl.text  = a['iban']      as String? ?? '';
      _bankCtrl.text  = a['bank_name'] as String? ?? '';
      _genre = a['genre'] as String?;
      if (_genre != null && !_genres.contains(_genre)) _genre = null;
    }
    setState(() {});
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(UpdateProfileEvent(
      name:     _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      bioAr:    _isArtist ? _bioArCtrl.text.trim() : null,
      bioEn:    _isArtist && _bioEnCtrl.text.trim().isNotEmpty
                    ? _bioEnCtrl.text.trim() : null,
      genre:    _isArtist ? (_genre ?? _genres.first) : null,
      iban:     _isArtist && _ibanCtrl.text.trim().isNotEmpty
                    ? _ibanCtrl.text.trim() : null,
      bankName: _isArtist && _bankCtrl.text.trim().isNotEmpty
                    ? _bankCtrl.text.trim() : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (ctx, state) {
        if (state is ProfileLoaded) _populate(state.data);
        if (state is ProfileSaved) {
          _loaded = false;
          _populate(state.data);
          _showSnack(s.changesSaved, NajmaColors.success);
        }
        if (state is ProfileError) {
          _showSnack(state.message, NajmaColors.error);
        }
      },
      child: Directionality(
        textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          body: SafeArea(
            child: Column(children: [
              _TopBar(title: s.editProfile),
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (ctx, state) {
                    if (state is ProfileLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: NajmaColors.gold, strokeWidth: 2),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            Center(child: _AvatarPicker(
                              initial: _nameCtrl.text.isNotEmpty
                                  ? _nameCtrl.text[0].toUpperCase() : '?',
                            )),
                            const SizedBox(height: 32),

                            _Section(s.basicInfo),
                            const SizedBox(height: 14),
                            _Field(
                              ctrl: _nameCtrl,
                              label: s.fullName,
                              hint: s.fullNameHint,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? s.fullNameRequired : null,
                            ),
                            const SizedBox(height: 12),
                            _ReadonlyField(
                              label: s.phone,
                              value: _phone.isNotEmpty ? _phone : '●●●●●●●●●',
                              icon: Icons.lock_outline,
                            ),

                            if (_isArtist) ...[
                              const SizedBox(height: 28),
                              _Section(s.artistInfo),
                              const SizedBox(height: 14),

                              _Field(
                                ctrl: _bioArCtrl,
                                label: s.bioAr,
                                hint: s.bioArHint,
                                maxLines: 3,
                                maxLength: 500,
                              ),
                              const SizedBox(height: 12),
                              _Field(
                                ctrl: _bioEnCtrl,
                                label: s.bioEn,
                                hint: s.bioEnHint,
                                maxLines: 2,
                                textDir: TextDirection.ltr,
                              ),
                              const SizedBox(height: 14),

                              // Genre
                              Text(s.genre,
                                  style: NajmaTextStyles.caption(
                                      size: 11, color: NajmaColors.textSecond)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: NajmaColors.surface,
                                  border: Border.all(
                                      color: NajmaColors.goldDim.withOpacity(0.25)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _genres.contains(_genre) ? _genre : _genres.first,
                                    isExpanded: true,
                                    dropdownColor: NajmaColors.surface2,
                                    style: NajmaTextStyles.body(size: 14),
                                    iconEnabledColor: NajmaColors.gold,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: _genres.map((g) =>
                                        DropdownMenuItem(value: g, child: Text(g))).toList(),
                                    onChanged: (v) => setState(() => _genre = v),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),
                              _Section(s.bankInfo),
                              const SizedBox(height: 14),
                              _Field(
                                ctrl: _ibanCtrl,
                                label: s.ibanNumber,
                                hint: 'SA...',
                                textDir: TextDirection.ltr,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                                  LengthLimitingTextInputFormatter(34),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _Field(
                                ctrl: _bankCtrl,
                                label: s.bankName,
                                hint: s.bankNameHint,
                              ),
                            ],

                            const SizedBox(height: 36),
                            BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (_, state) => NajmaButton(
                                label: s.saveChanges,
                                isLoading: state is ProfileSaving,
                                onTap: _save,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: NajmaTextStyles.body(size: 13, color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }
}

// ── Avatar Picker ─────────────────────────────────────────────────
class _AvatarPicker extends StatelessWidget {
  final String initial;
  const _AvatarPicker({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: 96, height: 96,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              NajmaColors.gold.withOpacity(0.2),
              NajmaColors.surface2,
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: NajmaColors.gold.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: NajmaColors.gold.withOpacity(0.15),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: Text(initial,
              style: NajmaTextStyles.heading(size: 36, color: NajmaColors.gold)),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: NajmaColors.gold,
            shape: BoxShape.circle,
            border: Border.all(color: NajmaColors.black, width: 2),
          ),
          child: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 15),
        ),
      ),
    ]);
  }
}

// ── Widgets ───────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3, height: 16, color: NajmaColors.gold),
      const SizedBox(width: 8),
      Text(title, style: NajmaTextStyles.heading(size: 14)),
    ]);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final TextDirection textDir;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl,
    required this.label,
    this.hint,
    this.maxLines   = 1,
    this.maxLength,
    this.textDir    = TextDirection.rtl,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: NajmaTextStyles.caption(size: 11, color: NajmaColors.textSecond)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        maxLines:   maxLines,
        maxLength:  maxLength,
        textDirection: textDir,
        inputFormatters: inputFormatters,
        validator:  validator,
        style: NajmaTextStyles.body(size: 14),
        decoration: InputDecoration(
          hintText:     hint,
          hintStyle:    NajmaTextStyles.caption(size: 13, color: NajmaColors.textDim),
          counterStyle: NajmaTextStyles.caption(size: 10),
          filled:       true,
          fillColor:    NajmaColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.25))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.25))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: NajmaColors.gold, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: NajmaColors.error)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: NajmaColors.error, width: 1.5)),
        ),
      ),
    ]);
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _ReadonlyField(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: NajmaTextStyles.caption(size: 11, color: NajmaColors.textSecond)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: NajmaColors.surface2,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(children: [
          Expanded(child: Text(value,
              style: NajmaTextStyles.body(size: 14, color: NajmaColors.textDim))),
          Icon(icon, color: NajmaColors.textDim, size: 16),
        ]),
      ),
    ]);
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(
            color: NajmaColors.goldDim.withOpacity(0.15))),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: NajmaColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: NajmaColors.gold, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Text(title, style: NajmaTextStyles.heading(size: 17)),
      ]),
    );
  }
}
