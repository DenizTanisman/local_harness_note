import 'dart:ui';

/// Fixed color palette for heatmap buckets (spec 5.1).
/// The single source of truth — rule JSON refers to colors by these names.
class HeatColors {
  HeatColors._();

  static const Map<String, Color> palette = {
    // 0/none → near-black slate; then a modern cyan → azure → indigo ramp.
    'black': Color(0xFF11151C),
    'white': Color(0xFFE6EDF3),
    'lightBlue': Color(0xFF56CCF2),
    'blue': Color(0xFF2F81F7),
    'darkBlue': Color(0xFF1E40AF),
    'lightYellow': Color(0xFFF8E3A1),
    'yellow': Color(0xFFD4A72C),
    'darkYellow': Color(0xFF9E6A03),
    'lightGreen': Color(0xFF56D364),
    'green': Color(0xFF2EA043),
    'darkGreen': Color(0xFF196C2E),
    'orange': Color(0xFFDB6D28),
    'lightPink': Color(0xFFF9A8D4),
    'pink': Color(0xFFEC4899),
    'darkPink': Color(0xFFBE185D),
    'red': Color(0xFFDA3633),
  };

  static Color of(String name) {
    final color = palette[name];
    if (color == null) {
      throw ArgumentError.value(name, 'name', 'Unknown heatmap color');
    }
    return color;
  }

  static bool isKnown(String name) => palette.containsKey(name);
}
