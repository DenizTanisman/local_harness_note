import 'dart:convert';

/// Core seed data (spec 4.3 + 5.2). Inserted once in the onCreate migration.
class SeedMetric {
  const SeedMetric({
    required this.key,
    required this.title,
    required this.inputType,
    this.unit,
    this.parentKey,
    this.starred = false,
    this.heatmapLabel,
    this.heatmapRule,
    this.options = const [],
  });

  final String key;
  final String title;
  final String inputType;
  final String? unit;
  final String? parentKey;
  final bool starred;
  final String? heatmapLabel;
  final String? heatmapRule;
  final List<String> options;
}

String _rule(String source, List<List<Object?>> buckets) => jsonEncode({
  'source': source,
  'buckets': [
    for (final b in buckets) {'min': b[0], 'max': b[1], 'color': b[2]},
  ],
});

/// The 12 protected seed records (CR-2): the 9 fixed heatmap rows plus
/// Development's seed children — deleting Marketing would break the
/// Development composite, so protection covers group integrity too.
final List<String> coreMetricKeys = seedMetrics
    .map((m) => m.key)
    .toList(growable: false);

/// Fixed heatmap row order for the 9 core metrics (spec 5.3).
const coreHeatmapOrder = [
  'software',
  'development',
  'money',
  'extra',
  'instagram',
  'sport',
  'brushing',
  'waste',
  'water',
];

final List<SeedMetric> seedMetrics = [
  SeedMetric(
    key: 'software',
    title: 'Software',
    inputType: 'int_text',
    unit: 'min',
    starred: true,
    heatmapLabel: 'Software',
    heatmapRule: _rule('num_value', [
      [0, 20, 'black'],
      [20, 40, 'lightBlue'],
      [40, 60, 'blue'],
      [60, null, 'darkBlue'],
    ]),
  ),
  SeedMetric(
    key: 'development',
    title: 'Development',
    inputType: 'composite',
    starred: true,
    heatmapLabel: 'Development',
    heatmapRule: _rule('filled_subcount', [
      [0, 1, 'black'],
      [1, 2, 'lightYellow'],
      [2, 3, 'yellow'],
      [3, null, 'darkYellow'],
    ]),
  ),
  SeedMetric(
    key: 'dev_marketing',
    title: 'Marketing',
    inputType: 'text',
    parentKey: 'development',
  ),
  SeedMetric(
    key: 'dev_leadership',
    title: 'Leadership',
    inputType: 'text',
    parentKey: 'development',
  ),
  SeedMetric(
    key: 'dev_social',
    title: 'Social',
    inputType: 'text',
    parentKey: 'development',
  ),
  SeedMetric(
    key: 'money',
    title: 'Money',
    inputType: 'money',
    unit: 'TL',
    starred: true,
    heatmapLabel: 'Money',
    heatmapRule: _rule('tx_sum_heatmap', [
      [0, 300, 'darkGreen'],
      [300, 600, 'green'],
      [600, 750, 'lightGreen'],
      [750, null, 'black'],
    ]),
  ),
  SeedMetric(
    key: 'extra',
    title: 'Extra',
    inputType: 'text',
    starred: true,
    heatmapLabel: 'Extra',
    heatmapRule: _rule('text_exists', [
      [0, 1, 'white'],
      [1, null, 'orange'],
    ]),
  ),
  SeedMetric(
    key: 'instagram',
    title: 'Instagram',
    inputType: 'int_text',
    unit: 'min',
    starred: true,
    heatmapLabel: 'Instagram',
    heatmapRule: _rule('num_value', [
      [0, 20, 'lightPink'],
      [20, 30, 'pink'],
      [30, 40, 'darkPink'],
      [40, null, 'black'],
    ]),
  ),
  SeedMetric(
    key: 'sport',
    title: 'Sport',
    inputType: 'int_text',
    unit: 'min',
    starred: true,
    heatmapLabel: 'Sport',
    // Degenerate first bucket: exactly 0 → white (spec 5.2).
    heatmapRule: _rule('num_value', [
      [0, 0, 'white'],
      [0, 60, 'blue'],
      [60, null, 'red'],
    ]),
  ),
  SeedMetric(
    key: 'brushing',
    title: 'Brushing',
    inputType: 'checkbox',
    starred: true,
    heatmapLabel: 'Brushing',
    heatmapRule: _rule('option_count', [
      [0, 2, 'darkYellow'],
      [2, 3, 'yellow'],
      [3, null, 'white'],
    ]),
    options: ['Morning', 'Noon', 'Evening'],
  ),
  SeedMetric(
    key: 'waste',
    title: 'Waste',
    inputType: 'checkbox',
    starred: true,
    heatmapLabel: 'Waste',
    heatmapRule: _rule('option_count', [
      [0, 1, 'white'],
      [1, null, 'red'],
    ]),
    options: ['Honest energy waste — yes'],
  ),
  SeedMetric(
    key: 'water',
    title: 'Water',
    inputType: 'int',
    unit: 'L',
    starred: true,
    heatmapLabel: 'Water',
    // Exactly 0 → black; 0<x<2 lightBlue (open point #3); 2–3 blue; 3+ darkBlue.
    heatmapRule: _rule('num_value', [
      [0, 0, 'black'],
      [0, 2, 'lightBlue'],
      [2, 3, 'blue'],
      [3, null, 'darkBlue'],
    ]),
  ),
];

class SeedCategory {
  const SeedCategory(
    this.direction,
    this.name, {
    this.essential = false,
    this.countsInHeatmap = false,
  });

  final String direction;
  final String name;
  final bool essential;
  final bool countsInHeatmap;
}

const List<SeedCategory> seedMoneyCategories = [
  SeedCategory('outcome', 'Rent', essential: true),
  SeedCategory('outcome', 'Bill', essential: true),
  SeedCategory('outcome', 'Food', countsInHeatmap: true),
  SeedCategory('outcome', 'Entertainment', countsInHeatmap: true),
  SeedCategory('income', 'Scholarship'),
];

/// Default app settings (spec 6.6 / 8).
const Map<String, String> seedSettings = {
  'morning_time': '08:00',
  'evening_time': '22:00',
  'quotes_enabled': 'true',
  'quote_lang': 'tr',
  'backup_enabled': 'false',
};
