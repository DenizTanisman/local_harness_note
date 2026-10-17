import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/tag_categories.dart';

/// The pixel icon of a main #tag on a soft tile in its category colour.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.tag, this.size = 32});

  /// A tag ("question", "yemek") or a category's suggested tag.
  final String tag;
  final double size;

  @override
  Widget build(BuildContext context) {
    final category = TagCategories.of(tag);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: category.color.withValues(alpha: 0.35)),
      ),
      child: SvgPicture.asset(
        category.asset,
        width: size * 0.62,
        height: size * 0.62,
        colorFilter: ColorFilter.mode(category.color, BlendMode.srcIn),
      ),
    );
  }
}
