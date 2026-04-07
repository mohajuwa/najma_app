
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../theme/app_theme.dart';
import '../router/app_router.dart';
import '../l10n/locale_notifier.dart';

class NajmaApp extends StatelessWidget {
  const NajmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleNotifier.instance,
      builder: (_, locale, __) {
        return MaterialApp.router(
          title: 'نجمة',
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

