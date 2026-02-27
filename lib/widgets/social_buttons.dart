import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SocialButton extends StatefulWidget {
  final String text;
  final String imagePath;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.imagePath,
    this.onPressed,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() => _controller.forward();

  void _handleTapUp() {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) => _handleTapUp(),
        onTapCancel: _handleTapCancel,
        child: Container(
          height: 50,
          width: 230,
          decoration: _buildButtonDecoration(),
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  BoxDecoration _buildButtonDecoration() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return BoxDecoration(
      color: isLight ? Colors.white : const Color(0xFF1E2329),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(color: AppColors.borderColor(isLight), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowColor(isLight),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Row _buildButtonContent() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          widget.imagePath,
          height: 28,
          width: 28,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        Text(
          widget.text,
          style: TextStyle(
            color: AppColors.textPrimaryFor(isLight),
            fontWeight: FontWeight.w500,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
