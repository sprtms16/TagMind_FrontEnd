class Tag {
  final int id; // Unique identifier for the tag
  final String name; // Name of the tag (e.g., "행복", "운동")
  final String category; // Category of the tag (e.g., "감정", "활동")
  final bool isDefault; // True if it's a default tag, false if purchasable
  final bool isPurchased; // True if the user has purchased this tag (relevant for IAP)

  // Constructor for the Tag model
  Tag({
    required this.id,
    required this.name,
    required this.category,
    this.isDefault = true,
    this.isPurchased = false,
  });

  // Factory constructor to create a Tag object from a JSON map.
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      isDefault: json['is_default'] ?? true, // Default to true if not provided
      isPurchased: json['is_purchased'] ?? false, // Default to false if not provided
    );
  }
}
