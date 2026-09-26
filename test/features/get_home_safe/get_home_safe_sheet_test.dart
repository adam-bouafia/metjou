import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/get_home_safe/data/get_home_safe_service.dart';
import 'package:metjou/features/get_home_safe/presentation/widgets/get_home_safe_sheet.dart';
import 'package:metjou/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _sheet({GetHomeSafeState? current}) => MaterialApp(
      locale: const Locale('en'),
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: GetHomeSafeSheet(current: current)),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('every minute shows the SMS cost warning', (tester) async {
    await tester.pumpWidget(_sheet());
    await tester.pumpAndSettle();
    expect(find.textContaining('60 per hour'), findsNothing);

    await tester.tap(find.text('Every 1 min'));
    await tester.pump();
    expect(find.textContaining('60 per hour'), findsOneWidget);
  });

  testWidgets('once mode asks for a date and time', (tester) async {
    await tester.pumpWidget(_sheet());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Once, at a set time'));
    await tester.pump();
    expect(find.text('Choose date and time'), findsOneWidget);
    expect(find.text('Every 5 min'), findsNothing);
  });

  testWidgets('a running schedule offers Stop', (tester) async {
    await tester.pumpWidget(_sheet(
      current: const GetHomeSafeState('0612345678', RepeatEvery(Duration(minutes: 7))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Every 7 min'), findsOneWidget);
  });
}
