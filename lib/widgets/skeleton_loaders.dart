import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated shimmer box — the building block for all skeleton loaders.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final base = isLight ? const Color(0xFFE4E8EE) : const Color(0xFF252B35);
    final highlight = isLight
        ? const Color(0xFFF4F6F8)
        : const Color(0xFF313849);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(base, highlight, _anim.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for the Profile screen — mirrors the avatar + fields layout.
class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Avatar circle
          const Center(
            child: SkeletonBox(width: 96, height: 96, borderRadius: 48),
          ),
          const SizedBox(height: 12),
          // Email line
          const Center(
            child: SkeletonBox(width: 160, height: 13, borderRadius: 6),
          ),
          const SizedBox(height: 32),
          // 6 form field placeholders
          for (int i = 0; i < 6; i++) ...[
            const SkeletonBox(height: 54, borderRadius: 12),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          // Save button placeholder
          const SkeletonBox(height: 52, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Skeleton for list screens (Chat History / Notifications).
class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const ListSkeletonLoader({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _ListItemSkeleton(),
    );
  }
}

class _ListItemSkeleton extends StatelessWidget {
  const _ListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF4F6F8) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 44, height: 44, borderRadius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, borderRadius: 6),
                SizedBox(height: 8),
                SkeletonBox(height: 11, borderRadius: 6),
                SizedBox(height: 5),
                SkeletonBox(width: 90, height: 10, borderRadius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
