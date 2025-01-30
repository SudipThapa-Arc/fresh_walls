import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double? value;
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.value,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 3,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
