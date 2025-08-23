class ImageModel {
  final int id;
  final String categoryName;
  final String subcategoryName;
  final String imageUrl;
  final String uploadedAt;

  ImageModel({
    required this.id,
    required this.categoryName,
    required this.subcategoryName,
    required this.imageUrl,
    required this.uploadedAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      categoryName: json['category_name'],
      subcategoryName: json['subcategory_name'],
      imageUrl: json['image'],
      uploadedAt: json['uploaded_at'],
    );
  }
}
