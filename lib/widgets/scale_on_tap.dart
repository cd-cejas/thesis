import 'package:flutter/material.dart';

class ScaleOnTap extends StatefulWidget {
  final Widget child;

  const ScaleOnTap({super.key, required this.child});

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap> {
  double _scale = 1.0;

  void _down(PointerDownEvent _) => setState(() => _scale = 0.97);
  void _up(PointerUpEvent _) => setState(() => _scale = 1.0);
  void _cancel(PointerCancelEvent _) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: _cancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
