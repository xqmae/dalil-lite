class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.name,
    required this.pageCount,
    required this.addedAt,
  });

  final String id;       // UUID; also the copied file's name
  final String name;     // the name the user picked, for display
  final int? pageCount;  // null means encrypted and not yet opened
  final DateTime addedAt;

  String get fileName => '$id.pdf';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pageCount': pageCount,
        'addedAt': addedAt.toIso8601String(),
      };

  factory LibraryItem.fromJson(Map<String, dynamic> json) => LibraryItem(
        id: json['id'] as String,
        name: json['name'] as String,
        pageCount: json['pageCount'] as int?,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}