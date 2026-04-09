import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_strings.dart';

// ─────────────────────────────── Base ────────────────────────────
class _StaticScreen extends StatelessWidget {
  final String title;
  final List<_Block> blocks;
  const _StaticScreen({required this.title, required this.blocks});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Directionality(
      textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        body: SafeArea(
          child: Column(children: [
            // Header
            Container(
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: blocks.map((b) => b.build()).toList(),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Block {
  final String? heading;
  final String body;
  const _Block({this.heading, required this.body});

  Widget build() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (heading != null) ...[
          Row(children: [
            Container(width: 3, height: 14, color: NajmaColors.gold),
            const SizedBox(width: 8),
            Expanded(child: Text(heading!,
                style: NajmaTextStyles.heading(size: 14))),
          ]),
          const SizedBox(height: 10),
        ],
        Text(body,
            style: NajmaTextStyles.body(size: 13, color: NajmaColors.textSecond)
                .copyWith(height: 1.9)),
      ]),
    );
  }
}

// ─────────────────────────────── Privacy Policy ───────────────────
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return _StaticScreen(
      title: s.privacyPolicy,
      blocks: s.isAr ? _arPrivacy : _enPrivacy,
    );
  }

  static const _arPrivacy = [
    _Block(body: 'تحرص منصة نجم السهرة على حماية بياناتك الشخصية واحترام خصوصيتك. يوضح هذا المستند كيفية جمع بياناتك واستخدامها وحمايتها.'),
    _Block(heading: '١. البيانات التي نجمعها',
        body: 'نقوم بجمع رقم جوالك عند التسجيل. للفنانين: البيانات الفنية كالسيرة الذاتية والتخصص والخدمات المقدمة. بيانات المعاملات المالية مشفّرة ومعالجتها عبر بوابة ميسر الآمنة. لا نجمع أي بيانات حساسة إضافية دون موافقتك الصريحة.'),
    _Block(heading: '٢. كيف نستخدم بياناتك',
        body: 'تُستخدم بياناتك حصرياً لتشغيل خدمات المنصة، وإتمام عمليات الحجز والدفع، وإرسال إشعارات ذات صلة بطلباتك. لا نبيع بياناتك لأي طرف ثالث.'),
    _Block(heading: '٣. أمان البيانات',
        body: 'نستخدم تشفير SSL/TLS لجميع الاتصالات بين التطبيق والخوادم. يتم تخزين البيانات على خوادم آمنة وفق أعلى المعايير التقنية. لا يتم الاحتفاظ بأرقام بطاقات الدفع على خوادمنا.'),
    _Block(heading: '٤. مشاركة البيانات',
        body: 'قد نشارك بياناتك مع مزودي الخدمات الضروريين (مثل بوابة الدفع) وذلك بالقدر اللازم فقط لإتمام الخدمة. جميع الشركاء ملتزمون بسياسات حماية البيانات الصارمة.'),
    _Block(heading: '٥. حقوقك',
        body: 'يحق لك في أي وقت طلب الاطلاع على بياناتك أو تعديلها أو حذفها من خلال إعدادات الحساب في التطبيق، أو التواصل مع فريق الدعم.'),
    _Block(heading: '٦. التواصل',
        body: 'لأي استفسارات حول هذه السياسة، تواصل معنا:\nالبريد الإلكتروني: privacy@najma.sa'),
    _Block(body: 'آخر تحديث: أبريل ٢٠٢٦'),
  ];

  static const _enPrivacy = [
    _Block(body: 'Najma Platform is committed to protecting your personal data and respecting your privacy. This document explains how we collect, use, and protect your data.'),
    _Block(heading: '1. Data We Collect',
        body: 'We collect your phone number upon registration. For artists: professional data such as biography, specialization, and services. Financial transaction data is encrypted and processed through the secure Moyasar gateway.'),
    _Block(heading: '2. How We Use Your Data',
        body: 'Your data is used exclusively to operate platform services, complete bookings and payments, and send notifications related to your requests. We do not sell your data to any third party.'),
    _Block(heading: '3. Data Security',
        body: 'We use SSL/TLS encryption for all communications between the app and servers. Data is stored on secure servers according to the highest technical standards.'),
    _Block(heading: '4. Data Sharing',
        body: 'We may share your data with necessary service providers (such as the payment gateway) only to the extent required to complete the service.'),
    _Block(heading: '5. Your Rights',
        body: 'You may at any time request access to, modification of, or deletion of your data through account settings or by contacting support.'),
    _Block(heading: '6. Contact',
        body: 'For any questions about this policy:\nEmail: privacy@najma.sa'),
    _Block(body: 'Last updated: April 2026'),
  ];
}

// ─────────────────────────────── Terms ───────────────────────────
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return _StaticScreen(
      title: s.termsConditions,
      blocks: s.isAr ? _arTerms : _enTerms,
    );
  }

  static const _arTerms = [
    _Block(body: 'باستخدامك لمنصة نجم السهرة، فإنك توافق على هذه الشروط والأحكام. يُرجى قراءتها بعناية قبل استخدام التطبيق.'),
    _Block(heading: '١. الوصف العام',
        body: 'نجمة منصة تربط الفنانين الموسيقيين والترفيهيين بالأفراد الراغبين في إضافة لمسات فنية خاصة لمناسباتهم داخل المملكة العربية السعودية.'),
    _Block(heading: '٢. شروط التسجيل',
        body: '• يجب أن يكون عمرك 18 عامًا أو أكثر.\n• يجب أن تقدم معلومات صحيحة ودقيقة عند التسجيل.\n• أنت مسؤول عن الحفاظ على سرية حسابك.\n• يُحظر إنشاء أكثر من حساب واحد.'),
    _Block(heading: '٣. شروط الفنانين',
        body: '• يلتزم الفنان بتقديم المعلومات الصحيحة عن خدماته وتخصصه.\n• على الفنان الالتزام بالطلبات المقبولة والحضور في الوقت المحدد.\n• تحتفظ نجم السهرة بحق تعليق أو إنهاء حساب أي فنان يخالف شروط الخدمة.\n• يستلم الفنان 85% من قيمة كل طلب بعد خصم عمولة المنصة.'),
    _Block(heading: '٤. سياسة الحجز والإلغاء',
        body: '• الإلغاء قبل 48 ساعة: استرداد كامل المبلغ.\n• الإلغاء قبل 24 ساعة: استرداد 50% من المبلغ.\n• الإلغاء في أقل من 24 ساعة: لا يوجد استرداد.'),
    _Block(heading: '٥. المدفوعات',
        body: 'جميع المدفوعات تتم عبر بوابة ميسر الآمنة. تُحوَّل المبالغ للفنانين خلال 3-5 أيام عمل بعد إتمام الخدمة.'),
    _Block(heading: '٦. المحتوى المحظور',
        body: 'يُحظر تمامًا تقديم أي محتوى مخالف للقوانين السعودية أو الآداب العامة. يُحظر استخدام المنصة لأغراض غير مشروعة.'),
    _Block(body: 'آخر تحديث: أبريل ٢٠٢٦'),
  ];

  static const _enTerms = [
    _Block(body: 'By using Najma Platform, you agree to these Terms & Conditions. Please read carefully before using the application.'),
    _Block(heading: '1. General Description',
        body: 'Najma is a platform connecting musical and entertainment artists with individuals wishing to add a special artistic touch to their events within Saudi Arabia.'),
    _Block(heading: '2. Registration Terms',
        body: '• You must be 18 years of age or older.\n• You must provide accurate and truthful information upon registration.\n• You are responsible for maintaining the confidentiality of your account.\n• Creating more than one account is prohibited.'),
    _Block(heading: '3. Artist Terms',
        body: '• Artists must provide accurate information about their services.\n• Artists must honor accepted requests and arrive on time.\n• Najma reserves the right to suspend or terminate any artist account that violates terms.\n• Artists receive 85% of each order value after the platform commission.'),
    _Block(heading: '4. Booking & Cancellation',
        body: '• Cancellation 48+ hours before: Full refund.\n• Cancellation 24 hours before: 50% refund.\n• Cancellation less than 24 hours: No refund.'),
    _Block(heading: '5. Payments',
        body: 'All payments are processed through the secure Moyasar gateway. Funds are transferred to artists within 3-5 business days after service completion.'),
    _Block(body: 'Last updated: April 2026'),
  ];
}

// ─────────────────────────────── About ───────────────────────────
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Directionality(
      textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        body: SafeArea(
          child: Column(children: [
            Container(
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
                Text(s.aboutApp, style: NajmaTextStyles.heading(size: 17)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  const SizedBox(height: 52),
                  // شعار
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [NajmaColors.goldDim, NajmaColors.goldBright, NajmaColors.gold, NajmaColors.goldBright, NajmaColors.goldDim],
                    ).createShader(b),
                    child: const Text('NAJM',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 14,
                          height: 1.0,
                        )),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'A L   S A H R A',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: NajmaColors.goldDim,
                      letterSpacing: 7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('نجم السهرة',
                      style: NajmaTextStyles.heading(size: 20, color: NajmaColors.gold)),
                  const SizedBox(height: 10),
                  Container(
                    width: 90, height: 0.7,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent, NajmaColors.goldBright, Colors.transparent,
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.isAr
                        ? 'حيث تلتقي الموهبة بلحظاتك المميزة'
                        : 'Where talent meets your special moments',
                    style: NajmaTextStyles.caption(size: 13, color: NajmaColors.textSecond),
                  ),
                  const SizedBox(height: 52),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(children: [
                      _InfoRow(label: s.isAr ? 'الإصدار'   : 'Version',    value: '1.0.0'),
                      _InfoRow(label: s.isAr ? 'المطوّر'   : 'Developer',  value: s.isAr ? 'فريق نجم السهرة' : 'Evening Star Team'),
                      _InfoRow(label: s.isAr ? 'التواصل'   : 'Contact',    value: 'support@najma.sa'),
                      _InfoRow(label: s.isAr ? 'الموقع'    : 'Website',    value: 'www.najma.sa'),
                      _InfoRow(label: s.isAr ? 'البلد'     : 'Country',    value: s.isAr ? 'المملكة العربية السعودية 🇸🇦' : 'Saudi Arabia 🇸🇦'),
                      _InfoRow(label: s.isAr ? 'الترخيص'   : 'License',    value: '© 2026 All rights reserved'),
                    ]),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.12)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(children: [
        Text(label,
            style: NajmaTextStyles.body(size: 13, color: NajmaColors.textSecond)),
        const Spacer(),
        Text(value, style: NajmaTextStyles.body(size: 13)),
      ]),
    );
  }
}

// ─────────────────────────────── Support ─────────────────────────
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return _StaticScreen(
      title: s.contactSupport,
      blocks: s.isAr ? _arSupport : _enSupport,
    );
  }

  static const _arSupport = [
    _Block(body: 'نحن هنا لمساعدتك! تواصل معنا عبر أي من القنوات التالية:'),
    _Block(heading: '📧 البريد الإلكتروني',
        body: 'support@najma.sa\nنرد خلال 24 ساعة في أيام العمل.'),
    _Block(heading: '📱 واتساب',
        body: '+966 5X XXX XXXX\nمتاح من الأحد إلى الخميس، ٩ صباحًا – ٦ مساءً.'),
    _Block(heading: '🐛 الإبلاغ عن مشكلة',
        body: 'إذا واجهت أي خطأ تقني، يُرجى إرسال وصف المشكلة مع لقطة الشاشة إلى البريد الإلكتروني أعلاه.'),
    _Block(heading: '💡 اقتراح ميزة',
        body: 'يسعدنا تلقي مقترحاتك لتحسين التطبيق. أرسل لنا رأيك على: feedback@najma.sa'),
  ];

  static const _enSupport = [
    _Block(body: 'We are here to help! Contact us through any of the following channels:'),
    _Block(heading: '📧 Email',
        body: 'support@najma.sa\nWe respond within 24 hours on business days.'),
    _Block(heading: '📱 WhatsApp',
        body: '+966 5X XXX XXXX\nAvailable Sunday to Thursday, 9 AM – 6 PM.'),
    _Block(heading: '🐛 Report a Problem',
        body: 'If you encounter a technical error, please send a description of the issue with a screenshot to the email above.'),
    _Block(heading: '💡 Suggest a Feature',
        body: 'We welcome your suggestions to improve the app. Send us your feedback at: feedback@najma.sa'),
  ];
}
