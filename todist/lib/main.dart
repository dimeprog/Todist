import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/todist.dart';

void main() {
  runApp(ProviderScope(child: const Todist()),);
}

