import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:metjou/core/localization/app_locale.dart';

class PolicyDialog extends StatelessWidget {
  const PolicyDialog({super.key, this.radius = 8, required this.document});

  final double radius;

  /// Base name in assets/legal, e.g. 'privacy_policy' or 'terms'.
  final String document;

  /// The document in the app language, English when there is no translation.
  Future<String> _load(String languageCode) async {
    try {
      return await rootBundle.loadString(
        'assets/legal/${document}_$languageCode.md',
      );
    } catch (_) {
      return rootBundle.loadString('assets/legal/${document}_en.md');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _load(Localizations.localeOf(context).languageCode),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Markdown(data: snapshot.data!);
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(radius),
                  bottomRight: Radius.circular(radius),
                ),
              ),
              alignment: Alignment.center,
              height: 50,
              width: double.infinity,
              child: Text(
                context.l10n.close,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.labelLarge?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
