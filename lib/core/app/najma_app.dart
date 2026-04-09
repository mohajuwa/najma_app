import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../theme/app_theme.dart';
import '../router/app_router.dart';
import '../l10n/locale_notifier.dart';
import '../network/api_client.dart';

class NajmaApp extends StatefulWidget {
  const NajmaApp({super.key});

  @override
  State<NajmaApp> createState() => _NajmaAppState();
}

class _NajmaAppState extends State<NajmaApp> {
  @override
  void initState() {
    super.initState();
    // ربط 401 redirect — ينتقل للـ OTP عند انتهاء التوكن
    ApiClient.setUnauthorizedCallback(() {
      AppRouter.router.go('/otp');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleNotifier.instance,
      builder: (_, locale, __) {
        return MaterialApp.router(
          title: 'نجم السهرة',
          debugShowCheckedModeBanner: false,
          theme: NajmaTheme.darkTheme,
          routerConfig: AppRouter.router,
          locale: locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
