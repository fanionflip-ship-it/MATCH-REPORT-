import 'package:flutter_test/flutter_test.dart';
import 'package:match_report_62/main.dart';

void main() {
  testWidgets('app starts and shows MATCH REPORT 62', (tester) async {
    await tester.pumpWidget(const MatchReportApp());
    expect(find.text('MATCH REPORT 62'), findsOneWidget);
  });
}
