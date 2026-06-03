import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/auth_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/notes/presentation/add_note_page.dart';
import '../../features/notes/presentation/home_page.dart';
import '../../features/splash/presentation/splash_page.dart';

// ---------------------------------------------------------------------------
// Redirect logic:
//   - If the user is already authenticated → skip splash/login → /home
//   - If the user tries to access /home without auth → /login
// ---------------------------------------------------------------------------
String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authStateProvider);
  final isLoggedIn = authState.value != null;
  final location = state.matchedLocation;

  // Let loading state pass through
  if (authState.isLoading) return null;

  if (isLoggedIn) {
    // Already authenticated — bounce away from auth pages
    if (location == '/splash' ||
        location == '/login' ||
        location == '/register') {
      return '/home';
    }
  } else {
    // Not authenticated — protect home and add-note
    if (location == '/home' || location == '/add-note') {
      return '/login';
    }
  }

  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  // Notifier that triggers GoRouter refresh on auth state changes
  final notifier = _AuthNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: '/add-note',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const AddNotePage(),
        ),
      ),
    ],
  );
});

// Smooth fade transition
CustomTransitionPage<void> _fadeTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

// Slide-up transition (used for modal-style pages)
CustomTransitionPage<void> _slideTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

// ---------------------------------------------------------------------------
// Notifier that tells GoRouter to re-evaluate routes on auth changes
// ---------------------------------------------------------------------------
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
