class Favorite {
  final String id;
  final String userId;
  final String bookId;

  Favorite({
    required this.id,
    required this.userId,
    required this.bookId,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['user_id'],
      bookId: json['book_id'],
    );
  }
}
