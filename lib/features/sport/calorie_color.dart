/// Calorie-day color rule (CR-3 §11). Compared against the FROZEN daily
/// target snapshot, never the live target — so past days never recolor.
///   intake < target − 100 → 'yellow'  (under)
///   intake > target + 100 → 'red'     (over)
///   otherwise             → 'green'
/// Returns null when there is no snapshot (no profile that day) → neutral.
String? calorieColor(double intake, double? targetSnapshot) {
  if (targetSnapshot == null) return null;
  if (intake < targetSnapshot - 100) return 'yellow';
  if (intake > targetSnapshot + 100) return 'red';
  return 'green';
}
