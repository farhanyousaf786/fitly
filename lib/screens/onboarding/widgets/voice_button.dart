import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class VoiceButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;
  final double size;
  final AnimationController? pulseController;

  const VoiceButton({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.size = 56,
    this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    if (pulseController != null) {
      return _buildPulsingButton();
    }
    return _buildSimpleButton();
  }

  Widget _buildPulsingButton() {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseController!,
        builder: (context, child) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _getGradient(),
              boxShadow: [
                BoxShadow(
                  color: _getShadowColor().withOpacity(
                    0.4 + (pulseController!.value * 0.2),
                  ),
                  blurRadius: 40 + (pulseController!.value * 20),
                  spreadRadius: pulseController!.value * 10,
                ),
              ],
            ),
            child: Icon(
              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: size * 0.44,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleButton() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: _getGradient(),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getShadowColor().withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    if (isRecording) {
      return LinearGradient(colors: [Colors.red, Colors.red.shade700]);
    }
    return LinearGradient(
      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
    );
  }

  Color _getShadowColor() {
    return isRecording ? Colors.red : AppColors.primary;
  }
}
