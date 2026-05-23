import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/theme_mode_provider.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/notifications/notifications_service.dart';
import '../features/security/pin_lock_page.dart';
import '../features/security/providers/security_provider.dart';

class NataSakuApp extends StatefulWidget {
  const NataSakuApp({super.key});

  @override
  State<NataSakuApp> createState() => _NataSakuAppState();
}

class _NataSakuAppState extends State<NataSakuApp> {
  @override
  void initState() {
    super.initState();
    // Listen to notification action triggers for custom deep links
    NotificationsService.onActionSelected.listen((actionId) {
      debugPrint('Notification Action Clicked: $actionId');
      
      // Map actions to AppRouter locations
      switch (actionId) {
        case 'action_jajan':
          AppRouter.router.go(AppRouter.transactions);
          break;
        case 'action_secure':
          AppRouter.router.go(AppRouter.savings);
          break;
        case 'action_budget':
          AppRouter.router.go(AppRouter.budget);
          break;
        case 'payload_dashboard':
        case 'dashboard':
          AppRouter.router.go(AppRouter.dashboard);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final securityState = ref.watch(securityProvider);
        final themeMode = ref.watch(themeModeProvider);

        return MaterialApp.router(
          title: 'NataSaku',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            // App-wide overlay for PIN Security
            if (securityState.isLocked) {
              return Stack(
                children: [
                  if (child != null) child,
                  // Overlay PinLockPage directly above the router
                  const Positioned.fill(
                    child: PinLockPage(mode: PinMode.unlock),
                  ),
                ],
              );
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
