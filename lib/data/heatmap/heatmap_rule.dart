import 'dart:convert';

import 'heat_colors.dart';

/// Where a heatmap rule reads its daily value from (spec 5.1).
enum HeatmapSource {
  numValue('num_value'),
  optionCount('option_count'),
  textExists('text_exists'),
  filledSubcount('filled_subcount'),
  txSumHeatmap('tx_sum_heatmap');

  const HeatmapSource(this.json);
  final String json;

  static HeatmapSource parse(String value) =>
      values.firstWhere((s) => s.json == value,
          orElse: () => throw FormatException('Unknown heatmap source: $value'));
}

/// One color band. [min] inclusive, [max] exclusive; max == null → +∞.
/// Degenerate bucket (min == max) matches that exact value only — used for
/// "exactly 0" bands (Sport white, Water black; spec open point #3).
class HeatmapBucket {
  const HeatmapBucket({required this.min, required this.max, required this.color});

  final double min;
  final double? max;
  final String color;

  bool matches(double value) {
    final upper = max;
    if (upper != null && upper == min) return value == min;
    return value >= min && (upper == null || value < upper);
  }

  factory HeatmapBucket.fromJson(Map<String, dynamic> json) {
    final color = json['color'] as String;
    if (!HeatColors.isKnown(color)) {
      throw FormatException('Unknown heatmap color: $color');
    }
    return HeatmapBucket(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      color: color,
    );
  }

  Map<String, dynamic> toJson() => {'min': min, 'max': max, 'color': color};
}

/// Data-driven heatmap rule stored in `metrics.heatmap_rule` (ADR-5).
/// Buckets are evaluated in order; the first match wins.
class HeatmapRule {
  const HeatmapRule({required this.source, required this.buckets});

  final HeatmapSource source;
  final List<HeatmapBucket> buckets;

  /// Color name for [value], or null when no bucket matches.
  String? colorFor(double value) {
    for (final bucket in buckets) {
      if (bucket.matches(value)) return bucket.color;
    }
    return null;
  }

  factory HeatmapRule.fromJson(Map<String, dynamic> json) {
    final buckets = (json['buckets'] as List)
        .cast<Map<String, dynamic>>()
        .map(HeatmapBucket.fromJson)
        .toList();
    if (buckets.isEmpty) {
      throw const FormatException('Heatmap rule has no buckets');
    }
    return HeatmapRule(
      source: HeatmapSource.parse(json['source'] as String),
      buckets: buckets,
    );
  }

  static HeatmapRule decode(String raw) =>
      HeatmapRule.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  String encode() => jsonEncode({
        'source': source.json,
        'buckets': [for (final b in buckets) b.toJson()],
      });
}
