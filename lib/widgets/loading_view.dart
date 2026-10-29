import 'package:flutter/material.dart';

/// Reusable loading component strictly using [CircularProgressIndicator].
/// Keeps the loading interface clean, simple, and consistent across screens.
class LoadingView extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingView({
    super.key,
    this.message,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F9D8A)),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
