import 'package:flutter/material.dart';

class ColorFilterWidget extends StatelessWidget {
  final Function(Color) onColorSelected;
  final Color? selectedColor;

  const ColorFilterWidget({
    super.key,
    required this.onColorSelected,
    this.selectedColor,
  });

  final List<ColorOption> colors = const [
    ColorOption(color: Colors.red, name: 'Red'),
    ColorOption(color: Colors.blue, name: 'Blue'),
    ColorOption(color: Colors.green, name: 'Green'),
    ColorOption(color: Colors.yellow, name: 'Yellow'),
    ColorOption(color: Colors.purple, name: 'Purple'),
    ColorOption(color: Colors.black, name: 'Black'),
    ColorOption(color: Colors.white, name: 'White'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = selectedColor == color.color;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Tooltip(
              message: color.name,
              child: InkWell(
                onTap: () => onColorSelected(color.color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ColorOption {
  final Color color;
  final String name;

  const ColorOption({required this.color, required this.name});
}
