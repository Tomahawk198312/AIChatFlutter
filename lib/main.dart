import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter error: ${details.exception}');
    };
      try {
      await dotenv.load(fileName: ".env");
      debugPrint('.env загружен');
    } catch (_) {
      debugPrint('.env не найден – используются настройки пользователя');
    }
    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Error starting app: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Text('Error: $e', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        title: 'AI Chat',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ru', 'RU'),
        supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF1E1E1E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF262626),
            foregroundColor: Colors.white,
          ),
          dialogTheme: const DialogTheme(
            backgroundColor: Color(0xFF333333),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            contentTextStyle: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.white),
            bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}