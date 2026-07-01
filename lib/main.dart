import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/flashcard_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env if available, catch error if missing
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Could not load .env file: $e");
  }

  runApp(const EduFlipApp());
}

class EduFlipApp extends StatelessWidget {
  const EduFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FlashcardProvider>(
          create: (_) => FlashcardProvider(),
          update: (_, auth, flashcards) {
            if (auth.isAuthenticated && auth.user?.id != null) {
              flashcards?.loadDecksForUser(auth.user!.id!);
            }
            return flashcards!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'EduFlip',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
