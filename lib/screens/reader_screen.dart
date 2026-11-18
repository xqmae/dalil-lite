import 'package:dalil_lite/library/library_paths.dart';
import 'package:material_ui/material_ui.dart';

import '../library/library_item.dart';
import '../pdf/pdf_engine.dart';
import '../pdf/pdfrx_engine.dart';
import '../widgets/pdf_page_text.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.item, this.password});

  final LibraryItem item;
  final String? password; // only set for encrypted items that were unlocked

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final PdfEngine _engine = PdfrxEngine();
  late final Future<void> _opened = _open();

  Future<void> _open() async {
    final file = await libraryFile(widget.item);
    await _engine.openPdf(file.path, password: widget.password);
  }

  @override
  void dispose() {
    _engine.closePdf();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: FutureBuilder<void>(
        future: _opened,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text("This file can't be opened."));
          }
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return PdfPageText(engine: _engine, index: 0);
        },
      ),
    );
  }
}