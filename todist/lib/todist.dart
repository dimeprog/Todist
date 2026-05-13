import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/core/app_theme.dart';
import 'package:todist/modules/auth/views/login.dart';
import 'package:todist/modules/todos/views/todos_page.dart';

class Todist extends ConsumerWidget {
  const Todist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Todist",
      theme: AppTheme.darkTheme,
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Current persisted session
          final session = supabase.auth.currentSession;

          // User already logged in
          if (session != null) {
            return const TodosPage();
          }

          // Not logged in
          return const LoginPage();
        },
      ),
      
    );
  }
}