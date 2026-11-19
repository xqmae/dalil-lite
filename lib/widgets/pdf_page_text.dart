import 'package:material_ui/material_ui.dart';

import '../pdf/pdf_engine.dart';

/// Shows the text of one page as real text, so a screen reader can read it.
class PdfPageText extends StatefulWidget {
  const PdfPageText({super.key, required this.engine, required this.index});

  final PdfEngine engine; // opened and closed by the caller
  final int index; // 0-based

  @override
  State<PdfPageText> createState() => _PdfPageTextState();
}

class _PdfPageTextState extends State<PdfPageText> {
  late Future<String> _text;

  @override
  void initState() {
    super.initState();
    _text = widget.engine.textOfPage(widget.index);
  }

  @override
  void didUpdateWidget(covariant PdfPageText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index || oldWidget.engine != widget.engine) {
      _text = widget.engine.textOfPage(widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _text,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Could not read this page.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final text = snapshot.data!;
        if (text.trim().isEmpty) {
          return const Center(child: Text('This page has no text.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(text, style: const TextStyle(fontSize: 18)),
        );
      },
    );
  }
}
