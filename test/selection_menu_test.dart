import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/core/selection_menu.dart';

void main() {
  testWidgets('a select-all that did not come from touch still shows '
      'Cut / Copy', (tester) async {
    final controller = TextEditingController(text: 'seçim denemesi metni');
    final focus = FocusNode();
    final menu = SelectionMenuOnRange(controller, focus);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(controller: controller, focusNode: focus),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    expect(find.text('Copy'), findsNothing);

    // What a keyboard's "select all" does: only the selection changes.
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
    await tester.pumpAndSettle();
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Cut'), findsOneWidget);

    menu.dispose();
  });
}
