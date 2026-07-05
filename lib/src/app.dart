import 'package:flutter/material.dart';

import 'core/app_controller.dart';
import 'core/app_storage.dart';
import 'theme/app_theme.dart';
import 'ui/app_shell.dart';
import 'ui/auth_screen.dart';

class WorkoutJournalApp extends StatefulWidget {
  const WorkoutJournalApp({super.key});

  @override
  State<WorkoutJournalApp> createState() => _WorkoutJournalAppState();
}

class _WorkoutJournalAppState extends State<WorkoutJournalApp> {
  late final AppController _controller;
  late final Future<void> _bootstrap;

  @override
  void initState() {
    super.initState();
    _controller = AppController(storage: AppStorage());
    _bootstrap = _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Журнал тренировок',
          theme: buildAppTheme(),
          debugShowCheckedModeBanner: false,
          home: FutureBuilder<void>(
            future: _bootstrap,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _BootstrapScreen();
              }

              if (!_controller.isSignedIn) {
                return AuthScreen(controller: _controller);
              }

              return AppShell(controller: _controller);
            },
          ),
        );
      },
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
