import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/workout_history_screen.dart';
import 'screens/workout_chart_screen.dart';
import 'screens/goal_tracker_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_workout_screen.dart';
import 'screens/edit_workout_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const FitTrackPro(),
    ),
  );
}

// Global cross-platform GoRouter configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.uri.path == '/login' || state.uri.path == '/register';

    if (!loggedIn && !loggingIn) {
      return '/login';
    }
    
    if (loggedIn && loggingIn) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const WorkoutHistoryScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const WorkoutChartScreen(),
    ),
    GoRoute(
      path: '/goals',
      builder: (context, state) => const GoalTrackerScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/add-workout',
      builder: (context, state) => const AddWorkoutScreen(),
    ),
    GoRoute(
      path: '/edit-workout',
      builder: (context, state) {
        final docId = state.uri.queryParameters['id'] ?? '';
        final exercise = state.uri.queryParameters['exercise'] ?? '';
        final duration = int.tryParse(state.uri.queryParameters['duration'] ?? '0') ?? 0;
        final calories = int.tryParse(state.uri.queryParameters['calories'] ?? '0') ?? 0;

        return EditWorkoutScreen(
          documentId: docId,
          exercise: exercise,
          duration: duration,
          calories: calories,
        );
      },
    ),
  ],
);

class FitTrackPro extends StatelessWidget {
  const FitTrackPro({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'FitTrack Pro',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}