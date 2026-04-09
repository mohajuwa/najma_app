import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/api_client.dart';

// ── يستخرج username نظيف من أي صيغة ─────────────────────────────
String _toUsername(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return '';
  if (s.startsWith('http://') || s.startsWith('https://')) {
    final uri = Uri.tryParse(s);
    if (uri != null) {
      final segs = uri.pathSegments.where((x) => x.isNotEmpty).toList();
      return segs.isNotEmpty ? segs.last.replaceFirst(RegExp(r'^@'), '') : '';
    }
  }
  return s.replaceFirst(RegExp(r'^@'), '');
}

// ── بيانات كل منصة ───────────────────────────────────────────────
class _Platform {
  final String       key;
  final String       label;
  final IconData     icon;
  final Color        color;
  final String       hint;       // placeholder
  final String       prefix;     // يُعرض أمام الـ field

  const _Platform({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.hint,
    this.prefix = '@',
  });
}

const _platforms = [
  _Platform(
    key:    'instagram',
    label:  'Instagram',
    icon:   FontAwesomeIcons.instagram,
    color:  Color(0xFFE1306C),
    hint:   'اسم المستخدم  (مثال: ahmed_art)',
  ),
  _Platform(
    key:    'snapchat',
    label:  'Snapchat',
    icon:   FontAwesomeIcons.snapchat,
    color:  Color(0xFFFFFC00),
    hint:   'اسم المستخدم  (مثال: ahmed_snap)',
  ),
  _Platform(
    key:    'twitter',
    label:  'X  (Twitter)',
    icon:   FontAwesomeIcons.xTwitter,
    color:  Color(0xFFE7E9EA),
    hint:   'اسم المستخدم  (مثال: ahmed_x)',
  ),
  _Platform(
    key:    'tiktok',
    label:  'TikTok',
    icon:   FontAwesomeIcons.tiktok,
    color:  Color(0xFF69C9D0),
    hint:   'اسم المستخدم  (مثال: ahmed_tiktok)',
  ),
  _Platform(
    key:    'youtube',
    label:  'YouTube',
    icon:   FontAwesomeIcons.youtube,
    color:  Color(0xFFFF0000),
    hint:   'اسم القناة  (مثال: ahmed_channel)',
    prefix: '',
  ),
];

// ════════════════════════════════════════════════════════════════
class SocialLinksScreen extends StatefulWidget {
  const SocialLinksScreen({super.key});

  @override
  State<SocialLinksScreen> createState() => _SocialLinksScreenState();
}

class _SocialLinksScreenState extends State<SocialLinksScreen> {
  final Map<String, TextEditingController> _ctrls = {
    for (final p in _platforms) p.key: TextEditingController(),
  };

  bool _loading = false;
  bool _saving  = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final res    = await ApiClient.dio.get('artists/profile');
      final social = (res.data['data']['social'] as Map<String, dynamic>?) ?? {};
      for (final p in _platforms) {
        final raw = social[p.key] as String? ?? '';
        // تنظيف: إذا كان URL كامل → استخرج username فقط
        _ctrls[p.key]!.text = _toUsername(raw);
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{};
      for (final p in _platforms) {
        final val = _toUsername(_ctrls[p.key]!.text);
        payload[p.key] = val.isEmpty ? null : val;
      }
      await ApiClient.dio.put('artists/profile', data: payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text('تم حفظ روابط السوشيال ✅'),
            backgroundColor: NajmaColors.gold,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text('حدث خطأ، حاول مرة أخرى'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        appBar: AppBar(
          backgroundColor: NajmaColors.black,
          elevation: 0,
          title: Text(
            'روابط التواصل الاجتماعي',
            style: NajmaTextStyles.heading(size: 16),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: NajmaColors.gold,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: NajmaColors.gold),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Info banner ────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: NajmaColors.surface,
                        border: Border.all(
                          color: NajmaColors.gold.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: NajmaColors.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'أدخل اسم مستخدمك فقط — لا تكتب الرابط الكامل\n'
                              'مثال: اكتب  ahmed_art  وليس  instagram.com/ahmed_art',
                              style: NajmaTextStyles.caption(
                                size: 12,
                                color: NajmaColors.textSecond,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── حقول المنصات ───────────────────────────────
                    ...(_platforms.map(
                      (p) => _PlatformField(
                        platform:   p,
                        controller: _ctrls[p.key]!,
                      ),
                    )),

                    const SizedBox(height: 32),

                    // ── زر الحفظ ───────────────────────────────────
                    SizedBox(
                      width:  double.infinity,
                      height: 52,
                      child: _saving
                          ? Container(
                              decoration: BoxDecoration(
                                color:        NajmaColors.gold.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                    color:       NajmaColors.black,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: _save,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:        NajmaColors.gold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'حفظ',
                                    style: NajmaTextStyles.body(
                                      size: 15,
                                      color: NajmaColors.black,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── حقل منصة واحدة ───────────────────────────────────────────────
class _PlatformField extends StatelessWidget {
  final _Platform              platform;
  final TextEditingController  controller;
  const _PlatformField({required this.platform, required this.controller});

  @override
  Widget build(BuildContext context) {
    final p = platform;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:        NajmaColors.surface,
        border:       Border.all(color: NajmaColors.goldDim.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // ── أيقونة المنصة ──────────────────────────────────────
          Container(
            width:  54,
            height: 56,
            decoration: BoxDecoration(
              color:        p.color.withOpacity(0.10),
              borderRadius: const BorderRadius.only(
                topRight:    Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: FaIcon(p.icon, color: p.color, size: 20),
            ),
          ),
          // ── بادئة @ ────────────────────────────────────────────
          if (p.prefix.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              p.prefix,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize:   15,
                color:      p.color.withOpacity(0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          // ── حقل الإدخال ────────────────────────────────────────
          Expanded(
            child: TextField(
              controller:     controller,
              style:          NajmaTextStyles.body(size: 13),
              textDirection:  TextDirection.ltr,
              keyboardType:   TextInputType.text,
              autocorrect:    false,
              // إزالة @ تلقائياً عند الكتابة
              onChanged: (v) {
                if (v.startsWith('@')) {
                  controller.value = controller.value.copyWith(
                    text:      v.replaceFirst('@', ''),
                    selection: TextSelection.collapsed(
                      offset: v.length - 1,
                    ),
                  );
                }
              },
              decoration: InputDecoration(
                border:          InputBorder.none,
                contentPadding:  const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical:   14,
                ),
                hintText:  p.hint,
                hintStyle: NajmaTextStyles.body(
                  size:  12,
                  color: NajmaColors.textDim,
                ),
                labelText:  p.label,
                labelStyle: NajmaTextStyles.caption(
                  size:  11,
                  color: p.color.withOpacity(0.75),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
