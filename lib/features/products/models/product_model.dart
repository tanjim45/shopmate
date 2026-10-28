
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingData = json['rating'];

    double parsedRating = 0.0;
    int parsedRatingCount = 0;

    if (ratingData is Map<String, dynamic>) {
      // Fake Store API format
      parsedRating =
          (ratingData['rate'] as num?)?.toDouble() ?? 0.0;
      parsedRatingCount =
          (ratingData['count'] as num?)?.toInt() ?? 0;
    } else if (ratingData is num) {
      // DummyJSON format
      parsedRating = ratingData.toDouble();

      final reviews = json['reviews'];
      if (reviews is List) {
        parsedRatingCount = reviews.length;
      }
    }

    final imageValue =
        json['image'] ?? json['thumbnail'] ??
        ((json['images'] is List &&
                (json['images'] as List).isNotEmpty)
            ? (json['images'] as List).first
            : '');

    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? 'Untitled Product',
      price: (json['price'] as num).toDouble(),
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      image: imageValue.toString(),
      rating: parsedRating,
      ratingCount: parsedRatingCount,
    );
  }
}
