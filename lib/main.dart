import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'di/injection.dart';
import 'ui/navigation/app_router.dart';

class SentryProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'provider': provider.name ?? provider.runtimeType.toString(),
      }),
    );
  }
}

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = AppConstants.sentryDsn;
      options.tracesSampleRate = 1.0;
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );

      await setupDependencies();

      runApp(
        ProviderScope(
          observers: [SentryProviderObserver()],
          child: const CozinheiApp(),
        ),
      );
    },
  );
}

class CozinheiApp extends ConsumerWidget {
  const CozinheiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Cozinhei',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('pt', 'BR')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      routerConfig: router,
      builder: (context, child) => Listener(
        onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: child!,
      ),
    );
  }
}
