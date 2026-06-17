import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 52,
    this.showText = true,
    this.fit = BoxFit.contain,
  });

  final double size;
  final bool showText;
  final BoxFit fit;

  static const _logoAsset = 'lib/assets/LOGO_ZAQVO.png';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.24),
          child: Image.asset(
            _logoAsset,
            width: showText ? size : size * 2.6,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => Icon(
              Icons.local_shipping_outlined,
              size: size,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            'Zaqvo',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
