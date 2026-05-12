import 'package:flutter/material.dart';
import 'package:todist/modules/todes/todos_page.dart';

class Todist extends StatelessWidget {
  const Todist({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Todist",
      theme: ThemeData.dark(),
      home: TodosPage(),
    );
  }
}