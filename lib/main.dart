import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'ui/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
  runApp(const PersonalNotesApp());
}

class PersonalNotesApp extends StatelessWidget {
  final AuthService? authService;
  const PersonalNotesApp({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotesProvider>(
          create: (_) => NotesProvider(),
          update: (_, authProvider, notesProvider) {
            final provider = notesProvider ?? NotesProvider();
            // Automatically synchronize user state, wipe on logout, cancel old streams
            provider.updateUser(authProvider.userId);
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Personal Notes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Automatically handles navigation based on user authentication state.
/// Ensures that unauthenticated users never access notes, and back navigation cannot return to private notes.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Initial splash / loading while Firebase auth status resolves
    if (!authProvider.isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      // Authenticated view placeholder until Phase 7 connects full NotesHomeScreen
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Notes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => context.read<AuthProvider>().signOut(),
            ),
          ],
        ),
        body: Center(
          child: Text('Logged in as: ${authProvider.userEmail ?? 'User'}'),
        ),
      );
    }

    return const LoginScreen();
  }
}
