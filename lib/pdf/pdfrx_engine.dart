import 'dart:io';
import 'dart:async';
import 'package:dalil_lite/pdf/pdf_engine.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfrxEngine implements PdfEngine {
  PdfDocument? _doc;

  @override
  int get pageCount {
    final doc = _doc;
    if (doc == null) throw StateError('open() has not succeeded');
    return doc.pages.length;
  }
  
  @override
  Future<void> openPdf(String path, {String? password}) async {
    if (!File(path).existsSync()) {
      throw PdfOpenException(PdfOpenReason.fileNotFound, 'File not found: $path');
    }
    try {
      _doc = await PdfDocument.openFile(
        path,
        passwordProvider: password == null ? null : createSimplePasswordProvider(password), // returns the password once, then null
      );
    } on PdfPasswordException catch (e) {
      throw PdfOpenException(PdfOpenReason.passwordProtected, e.message);
    } on PdfException catch (e) {
      throw PdfOpenException(PdfOpenReason.invalidPdf, e.message);
    } catch (e) {
      throw PdfOpenException(PdfOpenReason.unknownError, e.toString());
    }
  }

  @override
  Future<void> closePdf() async {
    await _doc?.dispose();
    _doc = null;
  }

  @override
  Future<String> textOfPage(int index) async {
    final doc = _doc;
    if (doc == null) throw StateError('open() has not succeeded');
    final text = await doc.pages[index].loadText();
    return text!.fullText;
  }
}