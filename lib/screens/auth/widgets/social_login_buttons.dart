import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Google Sign In
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement Google Sign In
          },
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Continue with Google'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Apple Sign In
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement Apple Sign In
          },
          icon: const Icon(Icons.apple),
          label: const Text('Continue with Apple'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}
