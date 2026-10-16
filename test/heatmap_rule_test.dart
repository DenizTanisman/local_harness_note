import 'package:local_harness_not/data/db/seed_data.dart';
import 'package:local_harness_not/theme/heat_colors.dart';
import 'package:local_harness_not/data/heatmap/heatmap_rule.dart';
import 'package:flutter_test/flutter_test.dart';

HeatmapRule _ruleOf(String key) => HeatmapRule.decode(
  seedMetrics.firstWhere((m) => m.key == key).heatmapRule!,
);

void main() {
  group('bucket semantics', () {
    test('min inclusive, max exclusive', () {
      final rule = _ruleOf('software');
      expect(rule.colorFor(20), 'lightBlue'); // boundary belongs to upper band
      expect(rule.colorFor(19.99), 'black');
    });

    test('max null means +infinity', () {
      expect(_ruleOf('software').colorFor(99999), 'darkBlue');
    });

    test('degenerate bucket matches exact value only', () {
      const bucket = HeatmapBucket(min: 0, max: 0, color: 'white');
      expect(bucket.matches(0), isTrue);
      expect(bucket.matches(0.5), isFalse);
    });

    test('unknown source and color rejected', () {
      expect(
        () => HeatmapRule.decode('{"source":"magic","buckets":[]}'),
        throwsFormatException,
      );
      expect(
        () => HeatmapRule.decode(
          '{"source":"num_value","buckets":[{"min":0,"max":null,"color":"ultraviolet"}]}',
        ),
        throwsFormatException,
      );
    });
  });

  group('spec 5.2 rule table', () {
    test('Software: 0-20 black, 20-40 lightBlue, 40-60 blue, 60+ darkBlue', () {
      final rule = _ruleOf('software');
      expect(rule.source, HeatmapSource.numValue);
      expect(rule.colorFor(0), 'black');
      expect(rule.colorFor(35), 'lightBlue'); // spec phase-3 example
      expect(rule.colorFor(40), 'blue');
      expect(rule.colorFor(60), 'darkBlue');
    });

    test('Development: filled subcount 0/1/2/3 (blue ramp)', () {
      final rule = _ruleOf('development');
      expect(rule.source, HeatmapSource.filledSubcount);
      expect(rule.colorFor(0), 'black');
      expect(rule.colorFor(1), 'lightBlue');
      expect(rule.colorFor(2), 'blue');
      expect(rule.colorFor(3), 'darkBlue');
    });

    test('Extra: text exists → blue, else black', () {
      final rule = _ruleOf('extra');
      expect(rule.source, HeatmapSource.textExists);
      expect(rule.colorFor(0), 'black');
      expect(rule.colorFor(1), 'blue');
    });

    test('Instagram: 0 black, 0-20 lightBlue, 20-40 blue, 40+ darkBlue', () {
      final rule = _ruleOf('instagram');
      expect(rule.colorFor(0), 'black');
      expect(rule.colorFor(10), 'lightBlue');
      expect(rule.colorFor(25), 'blue');
      expect(rule.colorFor(45), 'darkBlue');
    });

    test(
      'Sport: exactly 0 black, 0-30 lightBlue, 30-60 blue, 60+ darkBlue',
      () {
        final rule = _ruleOf('sport');
        expect(rule.colorFor(0), 'black');
        expect(rule.colorFor(1), 'lightBlue');
        expect(rule.colorFor(45), 'blue');
        expect(rule.colorFor(60), 'darkBlue');
      },
    );

    test('Brushing: 0 black, 1 lightBlue, 2 blue, 3 darkBlue', () {
      final rule = _ruleOf('brushing');
      expect(rule.source, HeatmapSource.optionCount);
      expect(rule.colorFor(0), 'black');
      expect(rule.colorFor(1), 'lightBlue');
      expect(rule.colorFor(2), 'blue');
      expect(rule.colorFor(3), 'darkBlue');
    });

    test('Waste: selected → blue, empty → black', () {
      final rule = _ruleOf('waste');
      expect(rule.colorFor(0), 'black');
      expect(rule.colorFor(1), 'blue');
    });

    test('Water: exactly 0 black, 0<x<2 lightBlue, 2-3 blue, 3+ darkBlue', () {
      final rule = _ruleOf('water');
      expect(rule.colorFor(0), 'black');
      expect(rule.colorFor(0.5), 'lightBlue'); // open point #3
      expect(rule.colorFor(1.5), 'lightBlue');
      expect(rule.colorFor(2), 'blue');
      expect(rule.colorFor(3), 'darkBlue');
    });
  });

  group('palette', () {
    test('all 16 spec colors present', () {
      const expected = [
        'black',
        'white',
        'lightBlue',
        'blue',
        'darkBlue',
        'lightYellow',
        'yellow',
        'darkYellow',
        'lightGreen',
        'green',
        'darkGreen',
        'orange',
        'lightPink',
        'pink',
        'darkPink',
        'red',
      ];
      expect(HeatColors.palette.keys, unorderedEquals(expected));
    });

    test('unknown color name throws', () {
      expect(() => HeatColors.of('chartreuse'), throwsArgumentError);
    });
  });

  group('round trip', () {
    test('encode → decode preserves rule', () {
      final rule = _ruleOf('software');
      final round = HeatmapRule.decode(rule.encode());
      expect(round.source, rule.source);
      expect(round.buckets.length, rule.buckets.length);
      expect(round.colorFor(35), rule.colorFor(35));
    });
  });
}
