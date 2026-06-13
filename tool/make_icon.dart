import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Standalone launcher-icon renderer — run with `dart run tool/make_icon.dart`.
/// Brand: deep-navy background, electric-blue radial glow, neon-green
/// sparkline (the app's signature) with a peak dot.
///
/// Outputs (consumed by flutter_launcher_icons):
///   assets/icon/icon_background.png  navy + glow (adaptive background)
///   assets/icon/icon_foreground.png  sparkline only, transparent (foreground)
///   assets/icon/icon_full.png        composited, rounded (legacy fallback)
const _size = 1024;

// Brand palette.
const _navy = [5, 11, 24];
const _glow = [16, 58, 110];
const _accent = [46, 124, 246];
const _green = [57, 211, 83];

void _paintBackground(img.Image im) {
  final cx = _size * 0.5;
  final cy = _size * 0.34;
  final r = _size * 0.62;
  for (var y = 0; y < _size; y++) {
    for (var x = 0; x < _size; x++) {
      final d = math.sqrt(math.pow(x - cx, 2) + math.pow(y - cy, 2));
      final t = (0.62 * math.pow(math.max(0, 1 - d / r), 1.4)).toDouble();
      final rr = (_navy[0] * (1 - t) + _glow[0] * t).round();
      final gg = (_navy[1] * (1 - t) + _glow[1] * t).round();
      final bb = (_navy[2] * (1 - t) + _glow[2] * t).round();
      im.setPixelRgba(x, y, rr, gg, bb, 255);
    }
  }
}

void _paintSparkline(img.Image im, double inset) {
  final left = inset;
  final right = _size - inset;
  final width = right - left;
  final baseY = _size * 0.60;
  final peakY = _size * 0.32;
  final midY = _size * 0.48;
  final ys = <double>[
    baseY,
    baseY,
    midY,
    baseY,
    peakY,
    midY + (baseY - midY) * 0.45,
    baseY,
  ];
  final pts = [
    for (var i = 0; i < ys.length; i++)
      img.Point(left + width * i / (ys.length - 1), ys[i]),
  ];

  void poly(num thickness, img.Color color) {
    for (var i = 0; i < pts.length - 1; i++) {
      img.drawLine(
        im,
        x1: pts[i].xi,
        y1: pts[i].yi,
        x2: pts[i + 1].xi,
        y2: pts[i + 1].yi,
        color: color,
        thickness: thickness,
        antialias: true,
      );
    }
  }

  // Soft glow pass, then the crisp neon stroke.
  poly(_size * 0.06, img.ColorRgba8(_green[0], _green[1], _green[2], 90));
  poly(_size * 0.03, img.ColorRgba8(_green[0], _green[1], _green[2], 255));

  // Peak dot: halo → white ring → green core.
  final peak = pts[4];
  img.fillCircle(
    im,
    x: peak.xi,
    y: peak.yi,
    radius: (_size * 0.052).round(),
    color: img.ColorRgba8(_green[0], _green[1], _green[2], 90),
    antialias: true,
  );
  img.fillCircle(
    im,
    x: peak.xi,
    y: peak.yi,
    radius: (_size * 0.036).round(),
    color: img.ColorRgba8(255, 255, 255, 235),
    antialias: true,
  );
  img.fillCircle(
    im,
    x: peak.xi,
    y: peak.yi,
    radius: (_size * 0.028).round(),
    color: img.ColorRgba8(_green[0], _green[1], _green[2], 255),
    antialias: true,
  );

  // Electric-blue accent tick at the line's start.
  img.fillCircle(
    im,
    x: pts.first.xi,
    y: pts.first.yi,
    radius: (_size * 0.02).round(),
    color: img.ColorRgba8(_accent[0], _accent[1], _accent[2], 255),
    antialias: true,
  );
}

/// Zeroes the alpha outside a centered rounded rect (radius [r]).
void _roundCorners(img.Image im, double r) {
  final ri = r;
  bool outside(int x, int y) {
    final nx = x < ri
        ? ri - x
        : (x > _size - ri ? x - (_size - ri) : 0.0);
    final ny = y < ri
        ? ri - y
        : (y > _size - ri ? y - (_size - ri) : 0.0);
    return nx * nx + ny * ny > ri * ri;
  }

  for (var y = 0; y < _size; y++) {
    for (var x = 0; x < _size; x++) {
      if (outside(x, y)) im.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }
}

void main() {
  final dir = Directory('assets/icon')..createSync(recursive: true);

  // Background: navy + glow.
  final bg = img.Image(width: _size, height: _size, numChannels: 4);
  _paintBackground(bg);
  File('${dir.path}/icon_background.png').writeAsBytesSync(img.encodePng(bg));

  // Foreground: sparkline only, transparent, inside the adaptive safe zone.
  final fg = img.Image(width: _size, height: _size, numChannels: 4);
  img.fill(fg, color: img.ColorRgba8(0, 0, 0, 0));
  // Smaller inset here — the adaptive XML adds a further 16% margin.
  _paintSparkline(fg, _size * 0.14);
  File('${dir.path}/icon_foreground.png').writeAsBytesSync(img.encodePng(fg));

  // Full: composited + rounded corners (legacy fallback).
  final full = img.Image(width: _size, height: _size, numChannels: 4);
  _paintBackground(full);
  _paintSparkline(full, _size * 0.17);
  _roundCorners(full, _size * 0.22);
  File('${dir.path}/icon_full.png').writeAsBytesSync(img.encodePng(full));

  stdout.writeln('Wrote 3 icons to ${dir.path}');
}
