import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/state/task_controller.dart';
import 'features/tasks/presentation/pages/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(AuthRepository()),
        ),
        ChangeNotifierProxyProvider<AuthController, TaskController>(
          create: (_) => TaskController(TaskRepository()),
          update: (_, auth, previous) {
            final controller = previous ?? TaskController(TaskRepository());
            if (auth.uid != null) {
              controller.loadTasks(auth.uid!);
            } else {
              controller.clearTasks();
            }
            return controller;
          },
        ),
      ],
      child: MaterialApp(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return auth.isAuthenticated ? const HomePage() : const LoginPage();
  }
}
