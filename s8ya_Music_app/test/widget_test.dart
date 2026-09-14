import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s8ya/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.music_note,
            title: 'No Songs',
            subtitle: 'Your library is empty',
          ),
        ),
      ),
    );

    expect(find.text('No Songs'), findsOneWidget);
    expect(find.text('Your library is empty'), findsOneWidget);
  });
}
