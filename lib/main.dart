import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'config/router/app_router.dart';
import 'theme/app_theme.dart';
import 'package:sweph/sweph.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (e) {
    // Ignore error on unsupported platforms
  }

  // Initialize Swiss Ephemeris
  try {
    final appDir = await path_provider.getApplicationSupportDirectory();
    await Sweph.init(
      epheAssets: [
        "packages/sweph/assets/ephe/seas_18.se1",
      ],
      epheFilesPath: appDir.path,
      assetLoader: _FlutterAssetLoader(),
    );
  } catch (e) {
    print("Sweph init error: $e");
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

class _FlutterAssetLoader with AssetLoader {
  @override
  Future<Uint8List> load(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }
}
