import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_app/main.dart';
import 'package:music_player_app/screens/music_player_screen.dart';

void main() {
  testWidgets('Music player UI test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(MusicPlayerScreen), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
  });
}