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
                  ),
              ],
            ),
    );
  }
}