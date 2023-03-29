import 'package:flutter/material.dart';

class InjectPage extends StatefulWidget {
  const InjectPage({super.key});

  @override
  State<InjectPage> createState() => _InjectPageState();
}

class _InjectPageState extends State<InjectPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Card(
          child: Text("1"),
        )
      ],
    );
  }
}