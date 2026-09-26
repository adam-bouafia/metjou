import 'dart:io';

import 'package:flutter/services.dart';
import 'package:metjou/features/diary/data/diary.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds a PDF of all entries with their photos, for the police or
/// Veilig Thuis. Uses the app font so accents and Arabic render.
Future<File> exportDiaryPdf({
  required DiaryStore store,
  required List<DiaryEntry> entries,
  required String title,
  required String generatedLine,
  required String Function(DateTime) formatDate,
  required bool rtl,
}) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/ReadexPro-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/ReadexPro-Bold.ttf'),
  );
  final doc = pw.Document(title: title, creator: 'MetJou');
  final direction = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

  final content = <pw.Widget>[
    pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 22)),
    pw.SizedBox(height: 4),
    pw.Text(
      generatedLine,
      style: pw.TextStyle(
        font: regular,
        fontSize: 10,
        color: PdfColors.grey700,
      ),
    ),
    pw.SizedBox(height: 16),
  ];
  for (final e in entries.reversed) {
    content
      ..add(pw.Divider(color: PdfColors.grey400))
      ..add(
        pw.Text(
          formatDate(e.when),
          style: pw.TextStyle(font: bold, fontSize: 13),
        ),
      )
      ..add(pw.SizedBox(height: 6))
      ..add(pw.Text(e.text, style: pw.TextStyle(font: regular, fontSize: 11)));
    for (final name in e.photos) {
      final file = store.photo(name);
      if (!await file.exists()) continue;
      content
        ..add(pw.SizedBox(height: 8))
        ..add(
          pw.Image(
            pw.MemoryImage(await file.readAsBytes()),
            height: 240,
            fit: pw.BoxFit.contain,
          ),
        );
    }
    content.add(pw.SizedBox(height: 12));
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      textDirection: direction,
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      build: (_) => content,
    ),
  );
  final stamp = DateTime.now().toIso8601String().substring(0, 10);
  final out = File("${Directory.systemTemp.path}/metjou_diary_$stamp.pdf");
  await out.writeAsBytes(await doc.save());
  return out;
}
