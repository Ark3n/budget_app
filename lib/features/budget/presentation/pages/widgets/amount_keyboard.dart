import 'package:flutter/material.dart';

class AmountKeyboard extends StatelessWidget {
  final void Function(String value) onTap;

  const AmountKeyboard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '.',
      '0',
      'back',
    ];

    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.35,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];

        return OutlinedButton(
          onPressed: () => onTap(key),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.comfortable,
            shape: RoundedRectangleBorder(borderRadius: radius),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
            foregroundColor: theme.colorScheme.onSurface,
            backgroundColor: theme.colorScheme.surface,
          ),
          child: key == 'back'
              ? Icon(
                  Icons.backspace_outlined,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                )
              : Text(
                  key,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
        );
      },
    );
  }
}
