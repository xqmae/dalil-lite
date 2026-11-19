import 'dart:io';

import 'package:pdf/widgets.dart' as pw;

Future<void> main() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(child: pw.Text('Hello World!')),
    ),
  );

  final file = File('assets/fixtures/sample.pdf');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(await pdf.save());
}
