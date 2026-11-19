import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'library_item.dart';

abstract class LibraryRepository {
  Future<List<LibraryItem>> list();
  Future<void> add(LibraryItem item);
  Future<void> remove(String id);
}

class JsonLibraryRepository implements LibraryRepository {
  JsonLibraryRepository(this._indexFile);

  /// Use this in the app. Tests pass their own file to the constructor.
  static Future<JsonLibraryRepository> create() async {
    final dir = await getApplicationSupportDirectory();
    return JsonLibraryRepository(File('${dir.path}/library_index.json'));
  }

  final File _indexFile;

  // Queue for writes, so two quick adds can't overwrite each other.
  Future<void> _writes = Future.value();

  @override
  Future<List<LibraryItem>> list() async {
    if (!await _indexFile.exists()) return [];
    try {
      final raw = jsonDecode(await _indexFile.readAsString()) as List;
      return raw
          .map((e) => LibraryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Unreadable index: keep it as a backup instead of overwriting it.
      await _setAsideCorruptIndex();
      return [];
    }
  }

  @override
  Future<void> add(LibraryItem item) => _serialise(() async {
    final items = await list();
    items.add(item);
    await _write(items);
  });

  @override
  Future<void> remove(String id) => _serialise(() async {
    final items = await list();
    items.removeWhere((i) => i.id == id);
    await _write(items);
  });

  Future<void> _serialise(Future<void> Function() action) {
    final next = _writes.then((_) => action());
    _writes = next.catchError((_) {}); // keep the queue going after a failure
    return next;
  }

  Future<void> _write(List<LibraryItem> items) async {
    await _indexFile.parent.create(recursive: true);
    final tmp = File('${_indexFile.path}.tmp');
    await tmp.writeAsString(
      jsonEncode(items.map((i) => i.toJson()).toList()),
      flush: true,
    );
    // Writing to a temp file and then renaming it means a crash mid-write
    // leaves the old index intact.
    await tmp.rename(_indexFile.path);
  }

  Future<void> _setAsideCorruptIndex() async {
    final backup = File('${_indexFile.path}.corrupt');
    if (await backup.exists()) await backup.delete();
    await _indexFile.rename(backup.path);
  }
}
