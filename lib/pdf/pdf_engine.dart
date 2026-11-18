enum PdfOpenReason {
   /// The PDF file could not be found.
   fileNotFound,

   /// The PDF file is not a valid PDF document.
   invalidPdf,

   /// The PDF file is password protected and the password was not provided or incorrect.
   passwordProtected,

   /// An unknown error occurred while trying to open the PDF.
   unknownError,
 }

 class PdfOpenException implements Exception {
   final PdfOpenReason reason;
   final String? message;

   PdfOpenException(this.reason, [this.message]);

   @override
   String toString() {
     return 'PdfOpenException: $reason${message != null ? ' - $message' : ''}';
   }
 }

 abstract class PdfEngine {
   Future<void> openPdf(String path, {String? password});
   Future<void> closePdf();
   Future<String> textOfPage(int index);
 }