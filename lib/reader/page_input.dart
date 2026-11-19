/// Result of checking what the user typed in the go-to-page field.
sealed class PageInput {
  const PageInput();
}

class ValidPage extends PageInput {
  const ValidPage(this.index); // 0-based, ready for the engine
  final int index;
}

class InvalidPage extends PageInput {
  const InvalidPage(this.message);
  final String message;
}

/// Checks [text] as a 1-based page number for a document with [pageCount] pages.
PageInput parsePageInput(String text, int pageCount) {
  final trimmed = text.trim();
  final number = int.tryParse(trimmed);

  if (number == null) {
    return const InvalidPage('Enter a page number.');
  }
  if (number < 1 || number > pageCount) {
    return InvalidPage('Enter a number from 1 to $pageCount.');
  }
  return ValidPage(number - 1);
}