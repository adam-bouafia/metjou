import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/widgets/pin_guard.dart';
import 'package:metjou/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool?> _ask(WidgetTester tester) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await confirmPin(context),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('no PIN set: allowed right away', (tester) async {
    SharedPreferences.setMockInitialValues({});
    expect(await _ask(tester), isTrue);
  });

  testWidgets('wrong PIN is refused, right PIN unlocks', (tester) async {
    SharedPreferences.setMockInitialValues({'pin': 1234});
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: supportedAppLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await confirmPin(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(find.byType(EditableText), '0000');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Wrong PIN, try again'), findsOneWidget);
    expect(result, isNull);

    await tester.enterText(find.byType(EditableText), '1234');
    await tester.pump(const Duration(milliseconds: 500));
    expect(result, isTrue);
  });
}
