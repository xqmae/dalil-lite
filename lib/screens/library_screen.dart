import 'package:dalil_lite/library/library_paths.dart';
import 'package:dalil_lite/pdf/pdf_engine.dart';
import 'package:dalil_lite/pdf/pdfrx_engine.dart';
import 'package:dalil_lite/screens/reader_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:file_picker/file_picker.dart';

import '../library/import_service.dart';
import '../library/library_item.dart';
import '../library/library_repository.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryRepository? _repo;
  ImportService? _service;
  List<LibraryItem> _items = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  /// Creates the repository once and loads the saved list.
  Future<void> _setup() async {
    final repo = await JsonLibraryRepository.create();
    if (!mounted) return;
    setState(() {
      _repo = repo;
      _service = ImportService(repo);
    });
    await _reload();
  }

  Future<void> _reload() async {
    final repo = _repo;
    if (repo == null) return;
    final items = await repo.list();
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _import() async {
    final service = _service;
    if (service == null) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final file = result.firstOrNull; // null if the user cancelled
    if (file == null || file.path == null) return;

    setState(() => _busy = true);
    try {
      await service.importPdf(sourcePath: file.path!, displayName: file.name);
      await _reload();
    } on ImportException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Could not import this file.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _open(LibraryItem item) async {
  String? password;
  if (item.pageCount == null) {
    password = await _unlock(item);
    if (password == null) return; // cancelled
  }
  if (!mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ReaderScreen(item: item, password: password),
    ),
  );
}

/// Asks for a password until the file opens or the user cancels.
Future<String?> _unlock(LibraryItem item) async {
  final file = await libraryFile(item);
  var wrong = false;

  while (true) {
    if (!mounted) return null;
    final password = await askPassword(context, wrong: wrong);
    if (password == null) return null; // cancelled

    final engine = PdfrxEngine();
    try {
      await engine.openPdf(file.path, password: password);
      return password;
    } on PdfOpenException catch (e) {
      if (e.reason != PdfOpenReason.passwordProtected) {
        _showMessage("This file can't be opened.");
        return null;
      }
      wrong = true; // loop and ask again
    } finally {
      await engine.closePdf();
    }
  }
}

Future<void> _delete(LibraryItem item) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Delete ${item.name}?'),
      content: const Text('The copy stored in the app will be removed.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  final repo = _repo;
  if (repo == null) return;

  try {
    final file = await libraryFile(item);
    if (await file.exists()) await file.delete();
    await repo.remove(item.id);
  } catch (_) {
    _showMessage('Could not delete this file.');
  }
  await _reload();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      floatingActionButton: FloatingActionButton.extended(
        // Disabled until the repository is ready, and while an import runs.
        onPressed: (_busy || _service == null) ? null : _import,
        icon: const Icon(Icons.add),
        label: Text(_busy ? 'Importing…' : 'Import PDF'),
      ),
      body: _items.isEmpty
          ? const Center(child: Text('No PDFs yet. Use Import PDF to add one.'))
          : ListView(
              children: [
                for (final item in _items)
                  ListTile(
  title: Text(item.name),
  subtitle: Text(item.pageCount == null
      ? 'Page count unknown (encrypted)'
      : '${item.pageCount} pages'),
  onTap: () => _open(item),
  trailing: IconButton(
    tooltip: 'Delete ${item.name}',
    icon: const Icon(Icons.delete_outline),
    onPressed: () => _delete(item),
  ),
),
              ],
            ),
    );
  }
}

Future<String?> askPassword(BuildContext context, {bool wrong = false}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Password required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (wrong) const Text('That password is incorrect.'),
          TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'PDF password'),
            onSubmitted: (v) => Navigator.pop(ctx, v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: const Text('Open'),
        ),
      ],
    ),
  );
}