import 'package:fitness_webapp/backend/backend.dart';
import 'package:fitness_webapp/frontend/modules/admin/admin_module.dart';
import 'package:fitness_webapp/frontend/modules/auth/auth_module.dart';
import 'package:fitness_webapp/frontend/modules/user/user_module.dart';
import 'package:fitness_webapp/frontend/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Application root. Owns the shared [AppState], the FitPilot theme, and the
/// authentication gate that routes each role to its portal.
class FitPilotApp extends StatefulWidget {
  const FitPilotApp({super.key});

  @override
  State<FitPilotApp> createState() => _FitPilotAppState();
}

class _FitPilotAppState extends State<FitPilotApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    // Restore any persisted session so the user stays signed in across reloads.
    _state.restoreSession();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'MrPT',
        debugShowCheckedModeBanner: false,
        theme: buildFitPilotTheme(),
        home: const _AuthGate(),
      ),
    );
  }
}

/// Shows the login screen until a user signs in, then routes by role.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.currentUser;

    final Widget screen;
    if (!state.sessionRestored) {
      screen = const _SplashScreen();
    } else if (user == null) {
      screen = const LoginPage();
    } else {
      screen = const AdminDashboardPage();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(
        key: ValueKey(
          !state.sessionRestored ? 'splash' : (user?.id ?? 'login'),
        ),
        child: screen,
      ),
    );
  }
}

/// Brief loading screen shown while the persisted session is restored.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, color: AppColors.yellow, size: 56),
            SizedBox(height: 20),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                value: 0.6,
                strokeWidth: 2.6,
                color: AppColors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
