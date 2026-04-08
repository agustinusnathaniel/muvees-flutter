import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loggy/loggy.dart';
import 'package:muvees/core/config/routes/router.dart';
import 'package:muvees/core/page_models/theme_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = false;
  Loggy.initLoggy(
    logPrinter: StreamPrinter(
      const PrettyDeveloperPrinter(),
    ),
  );

  // Lock orientation to Portrait only
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModelProvider).themeMode;

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightScheme = lightDynamic ?? _defaultLightScheme;
        final ColorScheme darkScheme = darkDynamic ?? _defaultDarkScheme;

        final TextTheme textTheme = GoogleFonts.outfitTextTheme(
          ThemeData.light().textTheme,
        );

        final ThemeData lightTheme = ThemeData.from(
          colorScheme: lightScheme,
          textTheme: textTheme,
        );

        final ThemeData darkTheme = ThemeData.from(
          colorScheme: darkScheme,
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        );

        return MaterialApp.router(
          title: 'muvees',
          routerConfig: AppRouter.router,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
        );
      },
    );
  }
}

// Fallback color schemes when device doesn't support Material You
const ColorScheme _defaultLightScheme = ColorScheme.light(
  primary: Color(0xFF008080),
  secondary: Color(0xFF008080),
  tertiary: Color(0xFF008080),
);

const ColorScheme _defaultDarkScheme = ColorScheme.dark(
  primary: Color(0xFF4DB6AC),
  secondary: Color(0xFF4DB6AC),
  tertiary: Color(0xFF4DB6AC),
);
