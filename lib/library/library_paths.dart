import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'library_item.dart';

/// The copied PDF for [id], inside app storage. Creates the folder if needed.
Future<File> libraryFileById(String id) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/library');
  await dir.create(recursive: true);
  return File('${dir.path}/$id.pdf');
}

/// The copied PDF for [item]. Reader and library screens use this.
Future<File> libraryFile(LibraryItem item) => libraryFileById(item.id);