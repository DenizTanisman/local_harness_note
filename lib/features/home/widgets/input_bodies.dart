import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/debouncer.dart';
import '../../../data/db/app_database.dart';
import '../home_providers.dart';

/// Number-only body ('int'), e.g. Water.
class IntBody extends ConsumerStatefulWidget {
  const IntBody({super.key, required this.metric, required this.entry});

  final Metric metric;
  final Entry? entry;

  @override
  ConsumerState<IntBody> createState() => _IntBodyState();
}

class _IntBodyState extends ConsumerState<IntBody> {
  late final TextEditingController _controller;
  late final Debouncer _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.entry?.numValue));
    _debounce = Debouncer(ref.read(debounceDurationProvider));
  }

  @override
  void dispose() {
    _debounce.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
      decoration: InputDecoration(
        labelText: 'Value',
        suffixText: widget.metric.unit,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (raw) {
        final value = parseNum(raw);
        _debounce(() {
          ref
              .read(entryRepositoryProvider)
              .saveEntry(
                metricId: widget.metric.id,
                date: ref.read(homeDateProvider),
                numValue: value,
                keepExistingText: true,
              );
        });
      },
    );
  }
}

/// Free-text body ('text'), e.g. Extra.
class TextBody extends ConsumerStatefulWidget {
  const TextBody({
    super.key,
    required this.metric,
    required this.entry,
    this.hint,
  });

  final Metric metric;
  final Entry? entry;
  final String? hint;

  @override
  ConsumerState<TextBody> createState() => _TextBodyState();
}

class _TextBodyState extends ConsumerState<TextBody> {
  late final TextEditingController _controller;
  late final Debouncer _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry?.textValue ?? '');
    _debounce = Debouncer(ref.read(debounceDurationProvider));
  }

  @override
  void dispose() {
    _debounce.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: null,
      decoration: InputDecoration(
        labelText: widget.hint ?? 'Notes',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (raw) {
        final text = raw.trim().isEmpty ? null : raw;
        _debounce(() {
          ref
              .read(entryRepositoryProvider)
              .saveEntry(
                metricId: widget.metric.id,
                date: ref.read(homeDateProvider),
                textValue: text,
                keepExistingNum: true,
              );
        });
      },
    );
  }
}

/// Number + description ('int_text'), e.g. Software, Instagram, Sport.
/// The text field only opens when the number is > 0 (Sport rule, spec 4.2).
class IntTextBody extends ConsumerWidget {
  const IntTextBody({super.key, required this.metric, required this.entry});

  final Metric metric;
  final Entry? entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showText = (entry?.numValue ?? 0) > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntBody(metric: metric, entry: entry),
        if (showText) ...[
          const SizedBox(height: 8),
          TextBody(metric: metric, entry: entry, hint: 'What did you do?'),
        ],
      ],
    );
  }
}

/// Multi-select body ('checkbox'), e.g. Brushing, Waste.
class CheckboxBody extends ConsumerWidget {
  const CheckboxBody({
    super.key,
    required this.metric,
    required this.selectedOptionIds,
  });

  final Metric metric;
  final Set<int> selectedOptionIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(metricOptionsProvider(metric.id));
    return options.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
      data: (rows) => Column(
        children: [
          for (final option in rows)
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(option.label),
              value: selectedOptionIds.contains(option.id),
              onChanged: (checked) {
                ref
                    .read(entryRepositoryProvider)
                    .setOptionSelected(
                      metricId: metric.id,
                      optionId: option.id,
                      date: ref.read(homeDateProvider),
                      selected: checked ?? false,
                    );
              },
            ),
        ],
      ),
    );
  }
}

double? parseNum(String raw) {
  final cleaned = raw.replaceAll(',', '.').trim();
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

String _format(double? value) {
  if (value == null) return '';
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}
