import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'di/injection.dart';
import 'ui/navigation/app_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();
  runApp(
    const ProviderScope(
      child: CozinheiApp(),
    ),
  );
}

class CozinheiApp extends StatelessWidget {
  const CozinheiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cozinhei',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
