import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'ui/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/feed_service.dart';
import 'data/services/user_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/event_service.dart';
import 'data/services/invite_code_service.dart';
import 'data/services/geocoding_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/relationship_service.dart';
import 'data/services/cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/services/theme_service.dart';
import 'data/services/tts_service.dart';
import 'data/services/gemini_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyApp extends StatelessWidget {
  const MyApp(this._geminiApiKey, {super.key});

  final String _geminiApiKey;

  @override
  Widget build(BuildContext context) {
    final cacheService = CacheService();
    final apiService = ApiService();
    final authService = AuthService(cacheService);
    final userService = UserService(cacheService);
    final storageService = StorageService();
    final themeService = ThemeService(); // Initialize ThemeService
    final notificationService = NotificationService(authService);
    final relationshipService = RelationshipService(
      authService,
      notificationService,
    );
    final feedService = FeedService(
      authService,
      storageService,
      relationshipService,
    );
    final ttsService = TtsService();
    final eventService = EventService(authService, storageService);
    final inviteCodeService = InviteCodeService();
    final geocodingService = GeocodingService();
    final geminiService = GeminiService(_geminiApiKey);

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
        Provider<FeedService>.value(value: feedService),
        Provider<UserService>.value(value: userService),
        Provider<StorageService>.value(value: storageService),
        Provider<EventService>.value(value: eventService),
        Provider<EventService>.value(value: eventService),
        Provider<InviteCodeService>.value(value: inviteCodeService),
        Provider<GeocodingService>.value(value: geocodingService),
        ChangeNotifierProvider<TtsService>.value(value: ttsService),
        ChangeNotifierProvider<ThemeService>.value(
          value: themeService,
        ), // Provide ThemeService
        Provider<GeminiService>.value(value: geminiService),
        Provider<RelationshipService>.value(value: relationshipService),
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: Consumer<ThemeService>(
        builder: (context, theme, child) {
          return MaterialApp.router(
            title: 'Inclusive Connect',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.getTheme(
              isDark: false,
              highContrast: theme.highContrast,
              readableFont: theme.readableFont,
            ),
            darkTheme: AppTheme.getTheme(
              isDark: true,
              highContrast: theme.highContrast,
              readableFont: theme.readableFont,
            ),
            themeMode: ThemeMode
                .system, // Or handle theme switching strictly via ThemeService if desired, but system is fine to start
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(theme.textScaleFactor),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

// Set to true to run a one-time import of the JSON assets into Firestore.
// Keep false during normal app usage to avoid accidental writes.
const bool kRunImport = true;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter('hive_cache_data');
  await Hive.openBox('cache');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  runApp(MyApp(dotenv.env['GEMINI_API_KEY'] ?? ''));
}
