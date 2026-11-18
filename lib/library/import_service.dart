import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../pdf/pdf_engine.dart';
import '../pdf/pdfrx_engine.dart';
import 'library_item.dart';
import 'library_repository.dart';

class ImportException implements Exception {
  ImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ImportService {
  ImportService(this._repo);

  final LibraryRepository _repo;

  /// Copies the picked file into the library, checks it opens, and saves the record.
  /// Throws [ImportException] if the file is not a readable PDF.
  Future<LibraryItem> importPdf({
    required String sourcePath,
    required String displayName,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final libraryDir = Directory('${docs.path}/library');
    await libraryDir.create(recursive: true);

    final id = const Uuid().v4();
    final copy = File('${libraryDir.path}/$id.pdf');

    // Copy first, before any other await. Android's picker path is temporary.
    await File(sourcePath).copy(copy.path);

    try {
      final pageCount = await _readablePageCount(copy.path);
      final item = LibraryItem(
        id: id,
        name: displayName,
        pageCount: pageCount,
        addedAt: DateTime.now(),
      );
      await _repo.add(item);
      return item;
    } catch (_) {
      // Any failure leaves no copy and no record behind.
      if (await copy.exists()) await copy.delete();
      rethrow;
    }
  }

  /// Returns the page count, or null if the file is encrypted.
  /// Throws [ImportException] if it is not a readable PDF.
  Future<int?> _readablePageCount(String path) async {
    final engine = PdfrxEngine();
    try {
      await engine.openPdf(path); // no password on purpose
      return engine.pageCount;
    } on PdfOpenException catch (e) {
      if (e.reason == PdfOpenReason.passwordProtected) return null;
      throw ImportException("This file can't be opened as a PDF.");
    } finally {
      await engine.closePdf();
    }
  }
}