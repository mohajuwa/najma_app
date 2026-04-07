import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_button.dart';
import '../../../../core/storage/local_storage.dart';
import '../bloc/auth_bloc.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: const _OtpScreenBody(),
    );
  }
}

class _OtpScreenBody extends StatefulWidget {
  const _OtpScreenBody();
  @override
  State<_OtpScreenBody> createState() => _OtpScreenBodyState();
}

class _OtpScreenBodyState extends State<_OtpScreenBody>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0=phone, 1=otp
  String _phone = '';
  String _role = 'client';

  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  int _resendTimer = 60;
  Timer? _timer;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _role = LocalStorage.getRole() ?? 'client';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _resendTimer--);
      if (_resendTimer <= 0) t.cancel();
    });
  }

  void _switchToOtp(String phone) {
    setState(() {
      _step = 1;
      _phone = phone;
    });
    _animCtrl.reset();
    _animCtrl.forward();
    _startResendTimer();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _otpFocus[0].requestFocus();
    });
  }

  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  void _onOtpChanged(String val, int idx) {
    if (val.length == 1 && idx < 5) _otpFocus[idx + 1].requestFocus();
    if (val.isEmpty && idx > 0) _otpFocus[idx - 1].requestFocus();
    if (_otpValue.length == 6) _submitOtp();
  }

  void _submitPhone() {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 9) return;
    context.read<AuthBloc>().add(SendOtpEvent(phone));
  }

  void _submitOtp() {
    if (_otpValue.length != 6) return;
    context.read<AuthBloc>().add(
      VerifyOtpEvent(phone: _phone, otp: _otpValue, role: _role),
    );
  }

  void _resendOtp() {
    if (_resendTimer > 0) return;
    for (final c in _otpCtrls) c.clear();
    context.read<AuthBloc>().add(SendOtpEvent(_phone));
  }

  Future<void> _handleSuccess(AuthSuccess state) async {
    await LocalStorage.saveToken(state.token);
    await LocalStorage.saveRole(state.role);
    if (!mounted) return;
    context.go(state.role == 'artist' ? '/artist-dashboard' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is OtpSent)
          _switchToOtp(_phone.isEmpty ? _phoneCtrl.text.trim() : _phone);
        if (state is AuthSuccess) _handleSuccess(state);
        if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: NajmaTextStyles.body(size: 13, color: Colors.white),
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: NajmaColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      if (_step == 1)
                        GestureDetector(
                          onTap: () {
                            setState(() => _step = 0);
                            _animCtrl.reset();
                            _animCtrl.forward();
                            context.read<AuthBloc>().add(ResetAuthEvent());
                          },
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: NajmaColors.gold,
                            size: 20,
                          ),
                        ),
                      const Spacer(),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      if (_step == 0) _buildPhoneInput() else _buildOtpInput(),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (ctx, state) => NajmaButton(
                          label: _step == 0 ? 'إرسال رمز التحقق' : 'تأكيد',
                          isLoading: state is AuthLoading,
                          onTap: _step == 0 ? _submitPhone : _submitOtp,
                        ),
                      ),
                      if (_step == 1) ...[
                        const SizedBox(height: 20),
                        _buildResend(),
                      ],
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 36, height: 2, color: NajmaColors.gold),
        const SizedBox(height: 16),
        Text(
          _step == 0 ? 'أهلاً بك في نجمة' : 'أدخل رمز التحقق',
          style: NajmaTextStyles.display(size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          _step == 0
              ? 'سيُرسل رمز تحقق إلى رقم جوالك'
              : 'تم إرسال رمز مكوّن من 6 أرقام إلى\n+966 ${_phone.replaceAll(RegExp(r'^0'), '')}',
          style: NajmaTextStyles.body(size: 14, color: NajmaColors.textSecond),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الجوال',
          style: NajmaTextStyles.caption(
            size: 12,
            color: NajmaColors.textSecond,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: NajmaColors.surface,
            border: Border.all(color: NajmaColors.goldDim.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0xFF2A2520))),
                ),
                child: Text(
                  '+966',
                  style: NajmaTextStyles.body(
                    size: 15,
                    color: NajmaColors.gold,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: NajmaTextStyles.body(
                    size: 16,
                  ).copyWith(fontFamily: 'PlayfairDisplay', letterSpacing: 1.5),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    hintText: '05xxxxxxxx',
                    hintStyle: NajmaTextStyles.body(
                      size: 15,
                      color: NajmaColors.textDim,
                    ),
                  ),
                  onSubmitted: (_) => _submitPhone(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رمز التحقق',
          style: NajmaTextStyles.caption(
            size: 12,
            color: NajmaColors.textSecond,
          ),
        ),
        const SizedBox(height: 14),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (i) => _OtpBox(
                controller: _otpCtrls[i],
                focusNode: _otpFocus[i],
                onChanged: (val) => _onOtpChanged(val, i),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResend() {
    return Center(
      child: GestureDetector(
        onTap: _resendTimer == 0 ? _resendOtp : null,
        child: RichText(
          textDirection: TextDirection.rtl,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'لم تستلم الرمز؟  ',
                style: NajmaTextStyles.body(
                  size: 13,
                  color: NajmaColors.textDim,
                ),
              ),
              TextSpan(
                text: _resendTimer > 0
                    ? 'إعادة الإرسال بعد $_resendTimer ث'
                    : 'إعادة الإرسال',
                style: NajmaTextStyles.body(
                  size: 13,
                  color: _resendTimer > 0
                      ? NajmaColors.textDim
                      : NajmaColors.gold,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── OTP Box ──────────────────────────────────────────────────────
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });
  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 56,
      decoration: BoxDecoration(
        color: _focused ? const Color(0xFF1C1505) : NajmaColors.surface,
        border: Border.all(
          color: _focused
              ? NajmaColors.gold
              : NajmaColors.goldDim.withOpacity(0.25),
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: NajmaColors.gold.withOpacity(0.15),
                  blurRadius: 12,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: NajmaColors.goldBright,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
