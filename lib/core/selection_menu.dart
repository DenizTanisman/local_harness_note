import 'package:flutter/widgets.dart';

/// Flutter only shows Kes / Kopyala / Yapıştır for selections made by
/// touch. A select-all from the keyboard's own menu (SwiftKey, Samsung
/// Keyboard) leaves a selection with no menu. This shows the menu whenever
/// the selection grows from a cursor into a range, whatever made it.
class SelectionMenuOnRange {
  SelectionMenuOnRange(this.controller, this.focusNode) {
    _wasRange = !controller.selection.isCollapsed;
    controller.addListener(_onChange);
  }

  final TextEditingController controller;
  final FocusNode focusNode;
  late bool _wasRange;

  void _onChange() {
    final isRange =
        controller.selection.isValid && !controller.selection.isCollapsed;
    if (isRange && !_wasRange && focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // The FocusNode's context sits inside the EditableText.
        focusNode.context
            ?.findAncestorStateOfType<EditableTextState>()
            ?.showToolbar();
      });
    }
    _wasRange = isRange;
  }

  void dispose() => controller.removeListener(_onChange);
}
