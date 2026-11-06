import 'package:flutter/material.dart';

/// Kotak abu-abu berdenyut sebagai placeholder saat data sedang dimuat
class PulseBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  const PulseBox({super.key, this.width, required this.height, this.radius = 12});

  @override
  State<PulseBox> createState() => _PulseBoxState();
}

class _PulseBoxState extends State<PulseBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
              const Color(0xFFF1EFF7), const Color(0xFFE4E1EE), _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}