class Food {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory Food.fromFirestore(Map<String, dynamic> json, String documentId) {
    return Food(
      id: documentId,
      name: json['name'] ?? 'Món chưa đặt tên',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      // Nếu món cũ chưa có category, mặc định trả về 'Khác'
      category: json['category'] ?? 'Khác',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
