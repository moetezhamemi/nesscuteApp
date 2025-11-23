import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final authState = ref.read(authProvider);
      if (authState.token != null && authState.token!.isNotEmpty) {
        // Navigate based on role
        final role = authState.user?.role ?? '';
        if (role == 'ADMIN') {
          Navigator.pushReplacementNamed(context, AppRouter.adminDashboard);
        } else if (role == 'ASSISTANT') {
          Navigator.pushReplacementNamed(context, AppRouter.assistantOrders);
        } else {
          Navigator.pushReplacementNamed(context, AppRouter.clientHome);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    } catch (e) {
      // If there's an error, go to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'NessCute Restaurant',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

