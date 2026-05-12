import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/modules/auth/view_model/auth_notifier.dart';
import 'package:todist/modules/todos/views/todos_page.dart';

import '../view_model/auth_state.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(hintText: "Enter email"),
            ),
            SizedBox(height: 30),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              obscuringCharacter: "*",
              decoration: InputDecoration(hintText: "Enter password"),
            ),
            SizedBox(height: 40),
            Consumer(
              builder: (_, WidgetRef ref, __) {
                final isLoading =
                    ref.watch(authNotifierProvider) is Registering;
                ref.listen(authNotifierProvider, (p, n) {
                  if (n is Registered) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => TodosPage()),
                      (_) => false,
                    );
                    return;
                  }
                  if (n is RegisterFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(n.message)));
                    return;
                  }
                });
                return isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          ref
                              .read(authNotifierProvider.notifier)
                              .register(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                        },
                        child: Text('Register'),
                      );
              },
            ),
            SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "Aleady have have an account, "),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pop(context);
                      },
                    text: "Login",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
