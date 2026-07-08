import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'config/router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (e) {
    // Ignore error on unsupported platforms
  }

  // Lock to portrait for mobile (no-op on desktop/web)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080E20),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: CosmicVedApp(),
    ),
  );
}

class CosmicVedApp extends StatelessWidget {
  const CosmicVedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CosmicVed',
      debugShowCheckedModeBanner: false,

      // Router
      routerConfig: appRouter,

      // Themes
      theme: CosmicTheme.light(),
      darkTheme: CosmicTheme.dark(),
      themeMode: ThemeMode.dark, // Always dark by default

      // Locale
      locale: const Locale('en', 'IN'),

      // Builder for global MediaQuery customization
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const _SmoothScrollBehavior(),
          child: MediaQuery(
            // Prevent text scaling from OS settings disrupting the premium UI
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}

class _SmoothScrollBehavior extends ScrollBehavior {
  const _SmoothScrollBehavior();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
