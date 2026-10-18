# README screenshots

Taken on an Android emulator with demo data only — never from a real phone.

1. Make the demo media (any short clips will do; the seed expects these names) in a
   folder and serve it to the emulator, which reaches the Mac at `10.0.2.2`:

   ```sh
   # sabah.mp4 (3–8 min) · ogle.mp4 (≤3 min) · aksam.m4a (>8 min) · masa.jpg · ders.html
   (cd demo-media && python3 -m http.server 8899)
   ```

   `ders.html` is a lesson with a recall pack ([format](../../docs/lesson-format.md)).

2. On a fresh emulator install, run the seed once, then install the app over it:

   ```sh
   adb -s emulator-5554 shell pm clear dev.deniz.local_harness_not
   flutter build apk --release --target-platform android-arm64 -t tool/screenshots/seed_demo.dart
   adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk
   adb -s emulator-5554 shell am start -n dev.deniz.local_harness_not/.MainActivity
   # "Demo hazır" → build and install the app itself, then take the screenshots
   ```

3. Save them to `docs/screenshots/` at 1200 px height (`sips -Z 1200`).
