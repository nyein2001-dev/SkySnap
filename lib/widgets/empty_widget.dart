import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String emptyTitle;
  final String emptyMessage;

  const EmptyWidget({
    super.key,
    required this.emptyTitle,
    required this.emptyMessage,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          child: Icon(
            Icons.not_listed_location,
            size: 80,
            color: Colors.blue,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          emptyTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 16),
      ],
    ));
  }
}
