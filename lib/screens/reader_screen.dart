import 'package:dalil_lite/reader/page_input.dart';
import 'package:material_ui/material_ui.dart';

import '../library/library_item.dart';
import '../library/library_paths.dart';
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

  int _index = 0; // 0-based, the page currently shown
  final TextEditingController _pageField = TextEditingController();
  String? _pageError;

  Future<void> _open() async {
    final file = await libraryFile(widget.item);
    await _engine.openPdf(file.path, password: widget.password);
  }

  void _goTo(int index) {
    if (index < 0 || index >= _engine.pageCount) return;
    setState(() => _index = index);
  }

  @override
  void dispose() {
    _engine.closePdf();
    _pageField.dispose();
    super.dispose();
  }

  void _jumpFromField(int pageCount) {
    final result = parsePageInput(_pageField.text, pageCount);
    switch (result) {
      case ValidPage(:final index):
        setState(() {
          _pageError = null;
          _index = index;
        });
        _pageField.clear();
        FocusScope.of(context).unfocus();
      case InvalidPage(:final message):
        setState(() => _pageError = message);
    }
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

          final count = _engine.pageCount;
          if (count == 0) {
            return const Center(child: Text('This file has no pages.'));
          }

          final atFirst = _index == 0;
          final atLast = _index >= count - 1;

          return Column(
            children: [
              Expanded(
                // PdfPageText reloads its text when index changes.
                child: PdfPageText(engine: _engine, index: _index),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Previous page',
                    // onPressed: null disables the button.
                    onPressed: atFirst ? null : () => _goTo(_index - 1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('Page ${_index + 1} of $count'),
                  IconButton(
                    tooltip: 'Next page',
                    onPressed: atLast ? null : () => _goTo(_index + 1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _pageField,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                    labelText: 'Go to page',
                    errorText: _pageError,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _jumpFromField(count),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
