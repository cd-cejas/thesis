import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:unicons/unicons.dart';

/// The bouncing "Evaluate" FAB — identical to the one on HomeScreen.
/// Place this as [Scaffold.floatingActionButton] together with
/// [floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked].
class SharedEvaluateFab extends StatefulWidget {
  const SharedEvaluateFab({super.key});

  @override
  State<SharedEvaluateFab> createState() => _SharedEvaluateFabState();
}

class _SharedEvaluateFabState extends State<SharedEvaluateFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFACC15).withOpacity(0.6),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'evaluate_fab_tab',
          onPressed: () => Navigator.pushNamed(context, '/riasec_test'),
          backgroundColor: const Color(0xFFFACC15),
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            UniconsLine.clipboard_notes,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// Shared bottom navigation bar used in the four tab screens
/// (Profile, Chats, Notifications, Settings).
///
/// Use with [floatingActionButton: const SharedEvaluateFab()] and
/// [floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked]
/// on the parent [Scaffold] to get the notched FAB in the centre.
class SharedBottomNavBar extends StatelessWidget {
  /// 0 = Profile, 1 = Chats, 2 = Alerts, 3 = Settings
  final int currentIndex;

  const SharedBottomNavBar({super.key, required this.currentIndex});

  static const _routes = [
    '/profile',
    '/chat_history',
    '/notifications',
    '/settings',
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      height: 60,
      padding: EdgeInsets.zero,
      color: isLight ? AppColors.light2 : AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SharedNavItem(
            outlinedIcon: UniconsLine.user,
            filledIcon: UniconsLine.user_circle,
            label: 'Profile',
            isSelected: currentIndex == 0,
            isLight: isLight,
            onTap: () => _onTap(context, 0),
          ),
          _SharedNavItem(
            outlinedIcon: UniconsLine.comment_alt,
            filledIcon: UniconsLine.comment_alt_dots,
            label: 'Chats',
            isSelected: currentIndex == 1,
            isLight: isLight,
            onTap: () => _onTap(context, 1),
          ),
          const SizedBox(width: 60), // gap for FAB notch
          _SharedNavItem(
            outlinedIcon: UniconsLine.bell,
            filledIcon: UniconsLine.bell,
            label: 'Alerts',
            isSelected: currentIndex == 2,
            isLight: isLight,
            onTap: () => _onTap(context, 2),
          ),
          _SharedNavItem(
            outlinedIcon: UniconsLine.setting,
            filledIcon: UniconsLine.cog,
            label: 'Settings',
            isSelected: currentIndex == 3,
            isLight: isLight,
            onTap: () => _onTap(context, 3),
          ),
        ],
      ),
    );
  }
}

/// A single animated nav item that permanently highlights when [isSelected],
/// and scales + glows on press — matching the style in HomeScreen.
class _SharedNavItem extends StatefulWidget {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
  final bool isSelected;
  final bool isLight;
  final VoidCallback onTap;

  const _SharedNavItem({
    required this.outlinedIcon,
    required this.filledIcon,
    required this.label,
    required this.isSelected,
    required this.isLight,
    required this.onTap,
  });

  @override
  State<_SharedNavItem> createState() => _SharedNavItemState();
}

class _SharedNavItemState extends State<_SharedNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDown() {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onUp() {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _onCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isSelected || _isPressed;
    final idleColor = widget.isLight
        ? AppColors.light3
        : AppColors.textSecondary;
    final iconColor = active ? AppColors.primary : idleColor;
    // Glow intensity: full when selected, animated when just pressed
    final glowOpacity = widget.isSelected ? 0.55 : 0.55 * _glowAnimation.value;

    return GestureDetector(
      onTapDown: (_) => _onDown(),
      onTapUp: (_) => _onUp(),
      onTapCancel: _onCancel,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, _) {
          return AnimatedScale(
            scale: _isPressed ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: active
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(glowOpacity),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    active ? widget.filledIcon : widget.outlinedIcon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                Text(
                  widget.label,
                  style: TextStyle(fontSize: 10, color: iconColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
