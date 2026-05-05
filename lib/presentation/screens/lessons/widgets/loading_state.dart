
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class loading_state extends StatelessWidget {
  const loading_state({
    super.key,
    required this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message ?? 'Chargement...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}